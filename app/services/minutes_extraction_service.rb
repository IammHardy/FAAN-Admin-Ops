require "faraday"
require "json"
require "tempfile"
require "faraday/multipart"

class MinutesExtractionService
  OPENAI_BASE_URL = "https://api.openai.com/v1"

  def initialize(minute)
    @minute = minute
  end

  def call
    @minute.update!(status: :processing)

    transcript = transcribe_audio
    minutes_data = generate_minutes(transcript)

    @minute.update!(
      transcript: transcript,
      summary: minutes_data[:summary],
      action_items: minutes_data[:action_items],
      status: :completed
    )
  rescue StandardError => e
    @minute.update!(status: :failed)
    Rails.logger.error("Minutes extraction failed: #{e.message}")
    raise e
  end

  private

  # =========================
  # TRANSCRIPTION
  # =========================
  def transcribe_audio
  raise "No audio file attached" unless @minute.audio_file.attached?

  original_filename = @minute.audio_file.filename.to_s
  extension = File.extname(original_filename).presence || ".mp3"

  audio_path = Rails.root.join(
    "tmp",
    "minute-audio-#{@minute.id}-#{Time.current.to_i}#{extension}"
  )

  File.open(audio_path, "wb") do |file|
    file.write(@minute.audio_file.download)
  end

  command = [
    "curl",
    "https://api.openai.com/v1/audio/transcriptions",
    "-H", "Authorization: Bearer #{ENV.fetch("OPENAI_API_KEY")}",
    "-F", "model=whisper-1",
    "-F", "file=@#{audio_path}"
  ]

  stdout, stderr, status = Open3.capture3(*command)

  unless status.success?
    raise "OpenAI transcription failed: #{stderr.presence || stdout}"
  end

  body = JSON.parse(stdout)

  raise body["error"]["message"] if body["error"]

  body["text"]
rescue JSON::ParserError
  raise "OpenAI transcription returned invalid JSON: #{stdout}"
ensure
  File.delete(audio_path) if defined?(audio_path) && File.exist?(audio_path)
end

  # =========================
  # SUMMARY + ACTION ITEMS
  # =========================
  def generate_minutes(transcript)
  meeting_date = @minute.meeting_date&.strftime("%d %B %Y") || "Not stated"

  prompt = <<~PROMPT
    You are an administrative officer preparing official FAAN meeting minutes.

    Generate the minutes using this exact office format:

    MINUTES OF MEETING HELD WITH #{@minute.title.upcase} ON #{meeting_date.upcase} IN #{@minute.venue.to_s.upcase}.

    S/N    DISCUSSIONS

    1      OPENING.
           State when the meeting commenced and who welcomed attendees.

    2      AGENDA FOR THE MEETING
           State why the meeting was convened.

    3      KEY DISCUSSIONS
           Summarize the main issues discussed in clear paragraphs.

    4      CONTRIBUTIONS
           Capture relevant contributions from participants if mentioned.

    5      RESOLUTIONS / ACTION POINTS
           Use bullet points for resolutions and action points.

    6      CLOSING
           State appreciation, closing remarks, and adjournment time if mentioned.

    End with:

    HOD OPERATIONS                 SECRETARY
    ........................       ........................

    Keep the tone formal, administrative, and concise.
    Use the provided meeting title, date, and venue exactly.
    Do not invent names, time, attendees, or extra facts.
    If any detail is missing from the transcript, write "Not stated".

    Transcript:
    #{transcript}
  PROMPT

  response = Faraday.post("https://api.openai.com/v1/responses") do |req|
    req.headers["Authorization"] = "Bearer #{ENV.fetch("OPENAI_API_KEY")}"
    req.headers["Content-Type"] = "application/json"

    req.body = {
      model: "gpt-4.1-mini",
      input: prompt
    }.to_json
  end

  body = parse_json_response(response)

  text = body.dig("output", 0, "content", 0, "text").to_s

  {
    summary: text.strip,
    action_items: extract_action_items(text)
  }
end
  # =========================
  # HELPERS
  # =========================
  def extract_section(text, start_marker, end_marker)
    start_index = text.index(start_marker)
    return text.strip unless start_index

    start_index += start_marker.length
    end_index = end_marker ? text.index(end_marker) : nil

    if end_index
      text[start_index...end_index].strip
    else
      text[start_index..].strip
    end
  end

  def extract_action_items(text)
  section = text[/5\s+RESOLUTIONS \/ ACTION POINTS(.*?)(6\s+CLOSING|$)/m, 1]
  section.to_s.strip.presence || "No action items stated."
end

  def parse_json_response(response)
    unless response.success?
      raise "OpenAI request failed. Status: #{response.status}. Body: #{response.body.to_s.truncate(300)}"
    end

    JSON.parse(response.body)
  rescue JSON::ParserError
    raise "OpenAI returned a non-JSON response. Status: #{response.status}. Body: #{response.body.to_s.truncate(300)}"
  end
end