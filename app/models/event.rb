class Event < ApplicationRecord

  scope :weekly_recurring, -> { where(weekly_recurring: true)}
  scope :not_weekly_recurring, -> { where(weekly_recurring: false)}
  scope :opening, -> { where(kind: 'opening') }
  scope :appointment, -> { where(kind: 'appointment') }

  class << self

    #calculate the availabilities for the next 7 days of the parameter start_at
    def availabilities(start_at)
      start_at = start_at.to_date
      ends_at = start_at + 6

      availabilities = []

      openings = openings(start_at, ends_at)
      appointments = appointments(start_at, ends_at)

      (start_at..ends_at).each do |day|
        day_opening_slots = day_opening_slots(openings[day])

        if !day_opening_slots.empty?
          available_day_slots = available_slots(day_opening_slots, appointments[day])
          if !available_day_slots.empty?
            available_day_slots = available_day_slots.sort
          end
        end

        availabilities << formating_ouptut(day, available_day_slots)

      end

      availabilities
    end

    #Calculate the opening slots for one day
    def day_opening_slots(day_openings)
      available_day_slots = []

      day_openings.each do |o|
        (o.starts_at.to_i...o.ends_at.to_i).step(30.minutes) do |slot|
          the_slot = Time.at(slot).utc.to_datetime
          available_day_slots << the_slot unless available_day_slots.include?(the_slot)
        end
      end

      available_day_slots
    end


    #Fetch and format the openings from the data
    #returning format :
    #{Date : [Event]}
    def openings(start_at, ends_at)
      openings = {}

      weekly_openings = Event.opening.weekly_recurring.where('starts_at < ?', (ends_at+1).beginning_of_day)
      not_weekly_opening = Event.opening.not_weekly_recurring.where(starts_at: start_at..ends_at)

      (start_at..ends_at).each do |day|
        fixed_weekly_openings = []
        weekly_openings.select{ |event| event.starts_at.wday == day.wday }.each do |wo|
          fixed_weekly_openings << weekly_opening_to_fixed_opening(day, wo)
        end
        openings[day] = not_weekly_opening.select{ |event|  event.starts_at.to_date == day.to_date } + fixed_weekly_openings
      end

      openings
    end

    #Fetch and formate the appointments
    def appointments(start_at, ends_at)
      Event.appointment.where(starts_at: start_at.beginning_of_day..ends_at.midnight).group_by{ |d| d.starts_at.to_date }
    end

    #Reject the booked slots from the the opening day slots using the appointments
    def available_slots(day_opening_slots, appointments)
      return day_opening_slots if appointments.blank?
      appointments.each do |appointment|
        day_opening_slots.reject!{ |slot| slot < appointment.ends_at.to_datetime and slot >= appointment.starts_at.to_datetime }
      end

      day_opening_slots
    end

    #Translate the past weekly recurring openings to the appointment date
    def weekly_opening_to_fixed_opening(day, weekly_opening)
      days_to_add = (day.to_date - weekly_opening.starts_at.to_date).to_i.days
      weekly_opening.starts_at = weekly_opening.starts_at + days_to_add
      weekly_opening.ends_at = weekly_opening.ends_at + days_to_add

      weekly_opening
    end

    def formating_ouptut(day, available_day_slots)
      available_day_slots = available_day_slots.present? ? available_day_slots.map! {|slot| slot.strftime("%-H:%M")} : Array.new

      {date: day.to_date, slots: available_day_slots}
    end
  end

end
