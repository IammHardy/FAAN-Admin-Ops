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

  def transcribe_audio
  raise "No audio file attached" unless @minute.audio_file.attached?

  @minute.audio_file.open do |file|
    conn = Faraday.new(url: OPENAI_BASE_URL) do |f|
      f.request :multipart
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end

    payload = {
      file: Faraday::Multipart::FilePart.new(
        file.path,
        @minute.audio_file.content_type,
        @minute.audio_file.filename.to_s
      ),
      model: "gpt-4o-mini-transcribe"
    }

    response = conn.post("/audio/transcriptions") do |req|
      req.headers["Authorization"] = "Bearer #{ENV.fetch("OPENAI_API_KEY")}"
      req.body = payload
    end

    body = JSON.parse(response.body)

    raise body["error"]["message"] if body["error"]

    body["text"]
  end
end

  def generate_minutes(transcript)
    prompt = <<~PROMPT
      Convert the transcript below into formal meeting minutes.

      Return the response in this exact format:

      SUMMARY:
      A clear, professional summary of the meeting.

      ACTION ITEMS:
      - List each action item clearly.
      - Include responsible person if mentioned.
      - Include deadlines if mentioned.

      Transcript:
      #{transcript}
    PROMPT

    response = Faraday.post("#{OPENAI_BASE_URL}/responses") do |req|
      req.headers["Authorization"] = "Bearer #{ENV.fetch("OPENAI_API_KEY")}"
      req.headers["Content-Type"] = "application/json"

      req.body = {
        model: "gpt-4.1-mini",
        input: prompt
      }.to_json
    end

    body = JSON.parse(response.body)

    raise body["error"]["message"] if body["error"]

    text = body.dig("output", 0, "content", 0, "text").to_s

    {
      summary: extract_section(text, "SUMMARY:", "ACTION ITEMS:"),
      action_items: extract_section(text, "ACTION ITEMS:", nil)
    }
  end

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
end