require "spec_helper"

describe Lita::Handlers::Fridays, lita_handler: true do
  let(:presentation_manager) do
    Lita::Services::PresentationManager.new(described_class.new(robot).redis)
  end
  let!(:user) { Lita::User.create(123, name: "oscar") }
  let!(:room) { Lita::Room.create_or_update(132, name: "viernes") }

  describe "add presenter" do
    context "with user not in presenters list" do
      it "responds to user" do
        send_message("@lita considera a agustin para las presentaciones", as: user)
        expect(replies.last).to eq("se agregó a agustin a la lista de presentadores")
      end
    end
    context "with user in presenters list" do
      before { presentation_manager.add_to_presenters("agustin") }

      it "responds to user" do
        send_message("@lita considera a agustin para las presentaciones", as: user)
        expect(replies.last).to eq("agustin ya está en la lista")
      end
    end
  end

  describe "remove presenter" do
    context "with user in presenters list" do
      before { presentation_manager.add_to_presenters("agustin") }

      it "responds to user" do
        send_message("@lita ya no consideres a agustin para las presentaciones", as: user)
        expect(replies.last).to eq("se eliminó de la lista a agustin")
      end
    end

    context "with user not in presenters list" do
      it "responds to user" do
        send_message("@lita ya no consideres a agustin para las presentaciones", as: user)
        expect(replies.last).to eq("agustin no está en la lista")
      end
    end
  end

  describe "assign presenter" do
    before { presentation_manager.add_to_presenters("agustin") }

    it "responds to user" do
      send_message("@lita agustin va a presentar", as: user)
      expect(replies.last).to eq("agustin va a presentar el próximo Viernes!")
    end
  end

  describe "self assign" do
    before { presentation_manager.add_to_presenters("oscar") }

    it "responds to user" do
      send_message("@lita yo voy a presentar", as: user)
      expect(replies.last).to eq("super! tu presentarás el próximo Viernes!")
    end
  end

  describe "current presenter" do
    context "with presenter assigned" do
      before do
        presentation_manager.add_to_presenters("agustin")
        presentation_manager.assign_presenter("agustin")
      end

      context "with current topic" do
        before do
          presentation_manager.set_current_topic("cómo volar abajo del agua")
        end

        it "responds to user" do
          send_message("@lita quién va a presentar", as: user)
          expect(replies.last).to eq(
            "este Viernes presentará agustin sobre 'cómo volar abajo del agua'"
          )
        end
      end

      context "without current topic" do
        it "responds to user" do
          send_message("@lita quién va a presentar", as: user)
          expect(replies.last).to eq("este Viernes presentará agustin")
        end
      end
    end

    context "without presenter assigned" do
      it "responds to user" do
        send_message("@lita quién va a presentar", as: user)
        expect(replies.last).to eq("todavía no sé quién presenta este Viernes")
      end
    end
  end

  describe "add suggestion" do
    it "responds to user" do
      send_message("@lita propongo comprar harto café", as: user)
      expect(replies.last).to eq("agregué tu propuesta a la lista")
    end
  end

  describe "considered suggestions" do
    context "with considered suggestions" do
      before do
        presentation_manager.add_to_topics("comprar harto café")
      end

      it "responds to user" do
        send_message("@lita qué se ha propuesto", as: user)
        expect(replies.last).to eq("La gente ha propuesto:\n - (0) comprar harto café")
      end
    end

    context "without presenter assigned" do
      it "responds to user" do
        send_message("@lita qué se ha propuesto", as: user)
        expect(replies.last).to eq("No hay propuestas aún :(")
      end
    end
  end

  describe "set current topic" do
    context "with presenter" do
      before do
        presentation_manager.add_to_presenters("oscar")
        presentation_manager.assign_presenter("oscar")
      end

      it "responds to user" do
        send_message("@lita presentaré sobre cómo pelar papas", as: user)
        expect(replies.last).to eq("fijé el tema de la próxima presentación")
      end
    end

    context "without presenter" do
      it "responds to user" do
        send_message("@lita presentaré sobre cómo pelar papas", as: user)
        expect(replies.last).to eq("el tema lo eliges cuando presentas amiguito")
      end
    end
  end

  describe "current topic" do
    context "with current topic" do
      before do
        presentation_manager.set_current_topic("cómo pelar papas")
      end

      it "responds to user" do
        send_message("@lita sobre qué será la presentación", as: user)
        expect(replies.last).to eq("el tema fijado es 'cómo pelar papas'")
      end
    end

    context "without current topic" do
      it "responds to user" do
        send_message("@lita sobre qué será la presentación", as: user)
        expect(replies.last).to eq("aún no sé de qué se tratará la presentación")
      end
    end
  end

  describe "#announce_presenter" do
    let(:subject) { described_class.new(robot) }

    before do
      presentation_manager.add_to_presenters("oscar")
      presentation_manager.assign_presenter("oscar")
    end

    it "announces presenter" do
      subject.announce_presenter
      expect(replies.last).to eq("oscar presentará el próximo Viernes!")
    end
  end
end
