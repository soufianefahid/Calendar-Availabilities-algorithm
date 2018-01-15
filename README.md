# README

This project contains an implementation (Using Ruby on Rails) of a method that calculates the availabilities within a calendar.


Command to run my personal tests: "bin/rails test -b test/models/event_test.rb"

Extra tests need to be added to the folder: test/models/event_test.rb

The algorithm use: "calculate the availabilities for the next 7 days of the parameter start_at"

Algorithm explination:


  1- Fetch and format the openings from the data

    1-1- returning format :
            {Date : [Event]}

  2- Fetch and formate the appointments

  3- Calculate the opening slots for one day

  4-Reject the booked slots from the the opening day slots using the appointments

  5- Format and display the output