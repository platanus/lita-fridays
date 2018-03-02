require "spec_helper"
require 'pry'
require 'dotenv/load'

describe Lita::Services::PresentationManager, lita: true do
  let(:robot) { Lita::Robot.new(registry) }
  let(:subject) { described_class.new(Lita::Handlers::Fridays.new(robot).redis) }

  describe 'presenters' do
    let(:presenter) { "oscar" }

    it "returns a list of presenters" do
      expect(subject.presenters_list).to eq([])
    end

    it "adds presenters" do
      expect { subject.add_to_presenters(presenter) }.to change { subject.presenters_list }
        .from([]).to([presenter])
    end

    it "removes presenters" do
      subject.add_to_presenters(presenter)
      expect { subject.remove_from_presenters(presenter) }.to change { subject.presenters_list }
        .from([presenter]).to([])
    end

    it "returns the current presenter" do
      expect(subject.current_presenter).to be nil
    end

    it "assigns a presenter" do
      subject.add_to_presenters(presenter)
      expect { subject.assign_presenter(presenter) }.to change { subject.current_presenter }
        .from(nil).to(presenter)
    end

    it "picks a presenter" do
      subject.add_to_presenters(presenter)
      expect { subject.pick_presenter }.to change { subject.current_presenter }
        .from(nil).to(presenter)
    end

    it "resets the presenter" do
      subject.add_to_presenters(presenter)
      subject.assign_presenter(presenter)

      expect { subject.reset_presenter }.to change { subject.current_presenter }
        .from(presenter).to(nil)
    end
  end

  describe 'topics' do
    let(:topic_0) { "test_topic_0" }
    let(:topic_1) { "test_topic_1" }
    let(:topic) { "cómo jugar a la payaya" }

    def add_topics
      subject.add_to_topics(topic_0)
      subject.add_to_topics(topic_1)
    end

    it "returns a list of topics" do
      expect(subject.topics_list).to eq([])
    end

    it "adds topics" do
      expect { add_topics }.to change { subject.topics_list }
        .from([]).to([topic_0, topic_1])
    end

    it "removes topics" do
      add_topics
      expect { subject.remove_from_topics(1) }.to change { subject.topics_list }
        .from([topic_0, topic_1]).to([topic_0])
    end

    it "resets topics" do
      add_topics

      expect { subject.reset_topics }.to change { subject.topics_list }
        .from([topic_0, topic_1]).to([])
    end

    it "returns the current topic" do
      expect(subject.current_topic).to be nil
    end

    it "sets a current topic" do
      expect { subject.set_current_topic(topic) }.to change { subject.current_topic }
        .from(nil).to(topic)
    end

    it "resets the topic" do
      subject.set_current_topic(topic)

      expect { subject.reset_current_topic }.to change { subject.current_topic }
        .from(topic).to(nil)
    end
  end
end
