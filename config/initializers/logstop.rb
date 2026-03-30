# Configure Logstop to filter PII patterns from application logs
# This is a catch-all for PII that might slip through parameter filtering

Logstop.guard(Rails.logger)
