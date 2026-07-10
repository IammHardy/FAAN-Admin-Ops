# Be sure to restart your server when you modify this file.

# Application-wide Content Security Policy. This is a defense-in-depth measure
# that limits where scripts, styles, fonts and images may be loaded from, which
# significantly reduces the impact of any cross-site scripting (XSS) bug.
#
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data          # Google Fonts (fonts.gstatic.com), data: fonts
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self                          # inline scripts are allowed via per-request nonce
    policy.style_src   :self, :https, :unsafe_inline  # Tailwind + Google Fonts CSS + inline style attributes
    policy.connect_src :self, :https
    policy.base_uri    :self
    policy.form_action :self
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)

  # Enforce the policy in production. In development/test run it in report-only
  # mode so tools like web-console (which inject inline scripts on error pages)
  # keep working while still logging any violations.
  config.content_security_policy_report_only = !Rails.env.production?
end
