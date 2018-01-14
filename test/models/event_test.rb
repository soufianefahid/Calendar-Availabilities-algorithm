require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length

  end

  test "multiple weekly recurring and not weekly recurring openings" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 10:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 11:30"), ends_at: DateTime.parse("2014-08-04 14:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 15:00"), ends_at: DateTime.parse("2014-08-11 18:00"), weekly_recurring: false
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 12:00"), ends_at: DateTime.parse("2014-08-11 13:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal 10, availabilities[1][:slots].length
    assert_equal ["9:30", "10:00", "11:30", "13:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 15), availabilities[5][:date]
    assert_equal [], availabilities[0][:slots]

  end

  test "multiplte appointements without an opening" do

    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-01 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-08 15:00"), ends_at: DateTime.parse("2014-08-11 15:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-07")
    assert_equal Date.new(2014, 8, 07), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 8), availabilities[1][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal 7, availabilities.length

  end

  test "multiple opening events without appointements" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 08:00"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 14:30"), ends_at: DateTime.parse("2014-08-11 18:30"), weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse("2014-08-07")
    assert_equal DateTime.parse("2014-08-07"), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal DateTime.parse("2014-08-11"), availabilities[4][:date]
    assert_equal 17, availabilities[4][:slots].length
    assert_equal ["8:00", "8:30", "9:00", "9:30", "10:00", "10:30", "11:00", "11:30", "12:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[4][:slots]
    assert_equal 7, availabilities.length

  end

  test "multiple opening events without appointements and weekly recurring openings" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 08:00"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: false
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 14:30"), ends_at: DateTime.parse("2014-08-11 18:30"), weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse("2014-08-07")
    assert_equal DateTime.parse("2014-08-07"), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal DateTime.parse("2014-08-11"), availabilities[4][:date]
    assert_equal 8, availabilities[4][:slots].length
    assert_equal ["14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[4][:slots]

  end

  test "example for future opening events creation" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-10 09:30"), ends_at: DateTime.parse("2014-08-10 12:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-10 14:30"), ends_at: DateTime.parse("2014-08-10 18:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-03 14:30"), ends_at: DateTime.parse("2014-08-03 18:30"), weekly_recurring: false
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-03 15:00"), ends_at: DateTime.parse("2014-08-03 16:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-01")
    assert_equal Date.new(2014, 8, 1), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 2), availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 3), availabilities[2][:date]
    assert_equal ["14:30", "16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[2][:slots]
    assert_equal 7, availabilities.length

  end

  test "dupilcated opening with a booked day" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 14:00"), ends_at: DateTime.parse("2014-08-05 18:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-12 14:30"), ends_at: DateTime.parse("2014-08-05 18:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 14:30"), ends_at: DateTime.parse("2014-08-12 15:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 15:30"), ends_at: DateTime.parse("2014-08-12 16:00")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 16:00"), ends_at: DateTime.parse("2014-08-12 17:00")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 17:00"), ends_at: DateTime.parse("2014-08-12 18:30")


    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 12), availabilities[2][:date]
    assert_equal 1, availabilities[2][:slots].length
    assert_equal ["14:00"], availabilities[2][:slots]
    assert_equal 7, availabilities.length

  end

  test "separated openings" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 08:00"), ends_at: DateTime.parse("2014-08-05 10:30"), weekly_recurring: false
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 10:30"), ends_at: DateTime.parse("2014-08-05 12:00"), weekly_recurring: false
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-05 08:00"), ends_at: DateTime.parse("2014-08-05 10:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-05")
    assert_equal ["10:00", "10:30", "11:00", "11:30"], availabilities[0][:slots]

  end

  test "overlapping openings" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 08:00"), ends_at: DateTime.parse("2014-08-05 10:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-12 09:00"), ends_at: DateTime.parse("2014-08-12 11:00"), weekly_recurring: false
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-12 09:00"), ends_at: DateTime.parse("2014-08-12 10:00"), weekly_recurring: false
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 09:00"), ends_at: DateTime.parse("2014-08-12 09:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-12")
    assert_equal 5, availabilities[0][:slots].length

  end


  test "appointments_method" do

    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 15:00"), ends_at: DateTime.parse("2014-08-11 15:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-12 15:00"), ends_at: DateTime.parse("2014-08-12 15:30")

    appointments = Event.appointments(DateTime.parse("2014-08-06"), DateTime.parse("2014-08-14"))
    assert_equal 2, appointments.length

  end

   test "day_opening_slots method" do

    day_openings = Array.new
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 10:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 10:00"), ends_at: DateTime.parse("2014-08-04 10:30"), weekly_recurring: false

    the_day = DateTime.parse("2014-08-04")
    week_openings = Event.openings(DateTime.parse("2014-08-03"), DateTime.parse("2014-08-09"))
    day_openings = Event.day_opening_slots(week_openings[the_day])
    assert_equal 2, day_openings.length
    assert_equal 7, week_openings.length

   end

  test "openings method" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 12:30"), weekly_recurring: true

    the_day = Date.parse("2014-08-11")
    openings = Event.openings(Date.parse("2014-08-07"), Date.parse("2014-08-13"))

    assert_equal 2, openings[the_day].length
    assert_equal 7, openings.length

  end

  test "available_slots_method" do

    day_opening_slots = [DateTime.parse("2014-08-08 09:30"), DateTime.parse("2014-08-08 10:00"), DateTime.parse("2014-08-08 10:30"), DateTime.parse("2014-08-08 11:00"), DateTime.parse("2014-08-08 11:30"), DateTime.parse("2014-08-08 12:00")]
    appointments = []
    appointments << ( Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-08 09:30"), ends_at: DateTime.parse("2014-08-08 10:30") )
    appointments << ( Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-08 11:30"), ends_at: DateTime.parse("2014-08-08 12:00") )

    available_slots = Event.available_slots(day_opening_slots, appointments)
    assert_equal DateTime.parse("2014-08-08 10:30"), available_slots[0]
    assert_equal DateTime.parse("2014-08-08 11:00"), available_slots[1]
    assert_equal DateTime.parse("2014-08-08 12:00"), available_slots[2]
    assert_equal 3, available_slots.length

  end

  test "available_slots_method with no appointment" do

    day_opening_slots = [DateTime.parse("2014-08-08 09:30"), DateTime.parse("2014-08-08 10:00"), DateTime.parse("2014-08-08 10:30"), DateTime.parse("2014-08-08 11:00"), DateTime.parse("2014-08-08 11:30"), DateTime.parse("2014-08-08 12:00")]
    appointments = []
    appointments << ( Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-09 09:30"), ends_at: DateTime.parse("2014-08-09 10:30") )
    appointments << ( Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-09 11:30"), ends_at: DateTime.parse("2014-08-09 12:00") )

    available_slots = Event.available_slots(day_opening_slots, appointments)
    assert_equal DateTime.parse("2014-08-08 9:30"), available_slots[0]
    assert_equal DateTime.parse("2014-08-08 10:00"), available_slots[1]
    assert_equal DateTime.parse("2014-08-08 10:30"), available_slots[2]
    assert_equal 6, available_slots.length

  end

  test "weekly_opening_to_fixed_opening method" do

    weekly = Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 08:30"), ends_at: DateTime.parse("2014-08-04 10:00"), weekly_recurring: true
    day = Date.parse("2014-01-15")
    fixed = Event.weekly_opening_to_fixed_opening(day, weekly)
    assert_equal DateTime.parse("2014-01-15 08:30"), fixed.starts_at
    assert_equal DateTime.parse("2014-01-15 10:00"), fixed.ends_at

  end

end
