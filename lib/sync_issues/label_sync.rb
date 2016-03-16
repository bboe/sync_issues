require_relative 'error'
require 'safe_yaml/load'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class LabelSync
    attr_reader :do_work, :keep_existing, :labels

    def initialize(github, file_yaml)
      @github = github
      @labels = @keep_existing = nil
      @do_work = file_yaml.nil? ? false : parse_yaml(file_yaml)
    end

    def synchronize(repository)
      return unless @do_work
      existing = existing_labels(repository)
      make_changes(existing, repository)
    end

    private

    def add_labels(labels, repository)
      labels.each do |label, color|
        puts "\tadd label: #{label}"
        @github.client.add_label(repository.full_name, label, color)
      end
    end

    def delete_labels(labels, repository)
      labels.each do |label, _|
        if @keep_existing
          puts "\tkeeping label: #{label}"
        else
          puts "\tdelete label: #{label}"
          @github.client.delete_label!(repository.full_name, label)
        end
      end
    end

    def make_changes(existing, repository)
      changes = { add: [], update: [] }
      @labels.each do |label, color|
        if existing.include?(label)
          changes[:update] << [label, color] unless existing[label] == color
          existing.delete(label)
        else
          changes[:add] << [label, color]
        end
      end

      add_labels(changes[:add], repository)
      update_labels(changes[:update], repository)
      delete_labels(existing, repository)
    rescue Octokit::UnprocessableEntity => exc
      raise unless exc.errors.count == 1 && exc.errors[0][:resource] == 'Label'
      error = exc.errors[0]
      raise Error, "Label error: #{error[:code]} #{error[:field]}"
    end

    def existing_labels(repository)
      Hash[@github.labels(repository).map do |label|
        [label[:name], label[:color]]
      end]
    end

    def parse_yaml(yaml)
      data = SafeYAML.load(yaml)
      return nil unless data
      if data.include?('labels') && data['labels'].is_a?(Hash)
        @labels = Hash[data['labels'].map do |label, color|
          if color.is_a?(Integer)
            raise Error, 'Label error: add quotes around numeric color values'
          end
          [label, color.to_s.downcase]
        end]
      else
        @labels = {}
      end
      @keep_existing = data['keep_existing'] != false
      @labels.size > 0 || !@keep_existing
    rescue Psych::SyntaxError
      raise ParseError, 'invalid label yaml file'
    end

    def update_labels(labels, repository)
      labels.each do |label, color|
        puts "\tupdate label: #{label}"
        @github.client.update_label(repository.full_name, label, color: color)
      end
    end
  end
end
