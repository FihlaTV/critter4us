module Href

  module Task_Uis

    def self.edit_reservation_note_match
      '/2/task-uis/reservation/edit-note'
    end

    def self.edit_reservation_note_generator(reservation_id)
      edit_reservation_note_match + "?reservation_id=#{reservation_id}"
    end

    def self.make_reservation_copies_match
      '/2/task-uis/reservation/make-copies'
    end

    def self.make_reservation_copies_generator(reservation_id)
      make_reservation_copies_match + "?reservation_id=#{reservation_id}"
    end

  end


  module Reservation
    def self.note_raw(interpolation)
      "/2/reservations/#{interpolation}/note"
    end

    def self.note_match
      note_raw(:reservation_id.inspect)
    end

    def self.note_generator(reservation_id)
      note_raw(reservation_id)
    end

    def self.repetitions_raw(interpolation)
      "/2/reservations/#{interpolation}/repetitions"
    end

    def self.repetitions_match
      repetitions_raw(:reservation_id.inspect)
    end

    def self.repetitions_generator(reservation_id)
      repetitions_raw(reservation_id)
    end
  end

  # OLD
  def self.reservation_viewing_page(reservation_id)
    "/reservation/#{reservation_id}"
  end


end
