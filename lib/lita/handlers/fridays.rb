# coding: utf-8

require 'rufus-scheduler'

module Lita
  module Handlers
    class Fridays < Handler
      on :loaded, :load_on_start

      def initialize(robot)
        super
      end

      def load_on_start(_payload)
        create_schedule
      end

      def self.help_msg(route)
        { "fridays:
           #{t("help.#{route}.usage")}" => t("help.#{route}.description") }
      end

      # Routes.

      route(
        /considera\sa\s([^\s]+)\spara\slas\spresentaciones/,
        command: true,
        help: help_msg(:consider_presenter)
      ) do |response|
        mention_name = mention_name_from_response(response)
        success = presentation_manager.add_to_presenters(mention_name)
        if success
          response.reply(t(:will_consider_presenter, subject: mention_name))
        else
          response.reply(t(:presenter_already_considered, subject: mention_name))
        end
      end

      route(
        /ya\sno\sconsideres\sa\s([^\s]+)\spara\slas\spresentaciones/i,
        command: true,
        help: help_msg(:remove_presenter)
      ) do |response|
        mention_name = mention_name_from_response(response)
        if presentation_manager.remove_from_presenters(mention_name)
          response.reply(t(:presenter_removed, subject: mention_name))
        else
          response.reply(t(:presenter_already_removed, subject: mention_name))
        end
      end

      route(
        /([^\s]+)\s(va\sa\spresentar|presentará)/i,
        command: true,
        help: help_msg(:will_present)
      ) do |response|
        mention_name = mention_name_from_response(response)
        presentation_manager.assign_presenter(mention_name)
        response.reply(t(:will_present, subject: mention_name))
      end

      route(
        /yo\svoy\sa\spresentar/i,
        command: true,
        help: help_msg(:you_will_present)
      ) do |response|
        presentation_manager.assign_presenter(response.user.mention_name)
        response.reply(t(:you_will_present))
      end

      route(
        /qui(e|é)n\s(va\sa\spresentar|presenta)/i,
        command: true,
        help: help_msg(:current_presenter)
      ) do |response|
        current_presenter = presentation_manager.current_presenter
        if current_presenter.nil?
          response.reply(t(:no_current_presenter))
        else
          message = t(:current_presenter, subject: current_presenter)
          unless presentation_manager.current_topic.nil?
            message += " sobre '#{presentation_manager.current_topic}'"
          end
          response.reply(message)
        end
      end

      route(
        /propongo\s(.+)/i,
        command: true,
        help: help_msg(:will_consider_topic)
      ) do |response|
        presentation_manager.assign_presenter(response.user.mention_name)
        response.reply(t(:will_consider_topic))
      end

      route(
        /qu(e|é)\s(han|se\sha)\spropuesto/i,
        command: true,
        help: help_msg(:considered_topics)
      ) do |response|
        if presentation_manager.topics_list.empty?
          response.reply(t(:no_considered_topics))
        else
          response.reply(
            t(:considered_topics) +
              presentation_manager.topics_list
                                  .map.with_index { |t, i| " - (#{i}) #{t}" }
                                  .join("\n")
          )
        end
      end

      route(
        /ya\sno\sconsideres\sel\stema\s(d+)/i,
        command: true,
        help: help_msg(:remove_topic)
      ) do |response|
        id = response.matches[0][0].to_i

        if presentation_manager.remove_from_topics(id)
          response.reply(t(:topic_removed))
        else
          response.reply(t(:non_existant_topic))
        end
      end

      route(
        /elimina\stodas\slas\ssugerencias/i,
        command: true,
        help: help_msg(:topics_reset)
      ) do |response|
        presentation_manager.reset_topics
        response.reply(t(:topics_reset))
      end

      route(
        /presentaré\s(de|sobre)\s(.+)/i,
        command: true,
        help: help_msg(:set_current_topic)
      ) do |response|
        if response.user.mention_name == presentation_manager.current_presenter
          presentation_manager.set_current_topic(response.matches[0][1])
          response.reply(t(:set_current_topic))
        else
          response.reply(t(:cannot_set_current_topic))
        end
      end

      route(
        /(de|sobre)\squ(e|é)\sser(a|á)\sla\spresentaci(o|ó)n/i,
        command: true,
        help: help_msg(:current_topic)
      ) do |response|
        if current_topic = presentation_manager.current_topic
          response.reply(t(:current_topic, subject: current_topic))
        else
          response.reply(t(:no_current_topic))
        end
      end

      def announce_presenter
        current_presenter = presentation_manager.current_presenter

        user = Lita::User.find_by_mention_name(current_presenter)
        robot.send_message(Source.new(user: user), t(:you_will_present)) if user

        message = t(:announce_presenter, subject: current_presenter)
        unless presentation_manager.topics_list.empty?
          message += t(:considered_topics) +
            presentation_manager.topics_list.map { |t| " - #{t}" }.join("\n")
        end

        robot.send_message(
          Source.new(room: Lita::Room.find_by_name('viernes').id),
          message
        )
      end

      def create_schedule
        # scheduler = Rufus::Scheduler.new
        # scheduler.cron(ENV['ANNOUNCE_PRESENTER']) do
        #   presentation_manager.pick_presenter
        #   announce_presenter
        # end
        # scheduler.cron(ENV['RESET']) do
        #   presentation_manager.reset_presenter
        #   presentation_manager.reset_current_topic
        # end
      end

      private

      def mention_name_from_response(response)
        mention_name = response.matches[0][0]
        mention_name&.delete('@')
      end

      def presentation_manager
        @presentation_manager ||= Lita::Services::PresentationManager.new(redis)
      end

      Lita.register_handler(self)
    end
  end
end
