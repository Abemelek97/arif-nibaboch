#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 ENV_VAR_NAME" >&2
  exit 1
fi

VAR_NAME="$1"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KAMAL_FILE="$ROOT_DIR/backend/config/deploy.yml"
KAMAL_SECRET_FILE="$ROOT_DIR/backend/.kamal/secrets"
GITHUB_FILE="$ROOT_DIR/.github/workflows/deploy-staging.yml"

ruby -e '
var = ARGV[0]
path = ARGV[1]
lines = File.read(path).lines
return if lines.any? { |line| line.strip == "- #{var}" }

secret_index = lines.find_index { |line| line.strip == "secret:" }
if secret_index.nil?
  warn "Could not find env secret section in #{path}"
  exit 1
end

insert_at = secret_index + 1
while insert_at < lines.length && lines[insert_at].match?(/^\s+-\s+/)
  insert_at += 1
end

lines.insert(insert_at, "    - #{var}\n")
File.write(path, lines.join)
' "$VAR_NAME" "$KAMAL_FILE"

ruby -e '
var = ARGV[0]
path = ARGV[1]
lines = File.read(path).lines
return if lines.any? { |line| line.include?("#{var}:") }

deploy_index = lines.find_index { |line| line.strip == "deploy:" }
if deploy_index.nil?
  warn "Could not find deploy job in #{path}"
  exit 1
end

env_index = nil
((deploy_index + 1)...lines.length).each do |i|
  break if lines[i].match?(/^\S/)
  if lines[i].strip == "env:"
    env_index = i
    break
  end
end

if env_index.nil?
  warn "Could not find env section in deploy job in #{path}"
  exit 1
end

insert_at = env_index + 1
while insert_at < lines.length && lines[insert_at].match?(/^\s{6}\S+:/)
  insert_at += 1
end

lines.insert(insert_at, "      #{var}: ${{ secrets.#{var} }}\n")
File.write(path, lines.join)
' "$VAR_NAME" "$GITHUB_FILE"


ruby -e '
var = ARGV[0]
path = ARGV[1]
lines = File.read(path).lines
return if lines.any? { |line| line.strip == "#{var}=$#{var}" }


insert_at = 0
while insert_at < lines.length
  insert_at += 1
end

lines.insert(insert_at, "#{var}=$#{var}\n")
File.write(path, lines.join)
' "$VAR_NAME" "$KAMAL_SECRET_FILE"

echo "Added #{VAR_NAME} to Kamal and GitHub configs."
