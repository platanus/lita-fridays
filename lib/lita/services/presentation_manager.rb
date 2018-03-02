module Lita
  module Services
    class PresentationManager
      attr_accessor :redis

      def initialize(redis_instance)
        @redis = redis_instance
      end

      def presenters_list
        @redis.smembers("presenters").sort || []
      end

      def add_to_presenters(mention_name)
        @redis.sadd("presenters", mention_name)
      end

      def remove_from_presenters(mention_name)
        @redis.srem("presenters", mention_name)
      end

      def assign_presenter(mention_name)
        @redis.set("current_presenter", mention_name) if presenters_list.include?(mention_name)
      end

      def pick_presenter
        presenter = presenters_list.sample
        @redis.set("current_presenter", presenter)
      end

      def current_presenter
        @redis.get("current_presenter")
      end

      def reset_presenter
        @redis.del("current_presenter")
      end

      def topics_list
        @redis.smembers("topics").sort || []
      end

      def add_to_topics(topic)
        @redis.sadd("topics", topic)
      end

      def remove_from_topics(id)
        topic = topics_list[id]
        @redis.srem("topics", topic) unless topic.nil?
      end

      def current_topic
        @redis.get("current_topic")
      end

      def set_current_topic(topic)
        @redis.set("current_topic", topic)
      end

      def reset_current_topic
        @redis.del("current_topic")
      end

      def reset_topics
        @redis.del("topics")
      end
    end
  end
end
