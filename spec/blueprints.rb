require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  title        { Faker::Lorem.words.join }
  question     { "#{Faker::Lorem.words.join}?" }
  description  { Faker::Lorem.paragraph }
  email        { Faker::Internet.email }
  url          { "http://#{Faker::Internet.domain_name}" }
  password     { rand(36**8).to_s(36) }
  name         { Faker::Lorem.words.first }
end

User.blueprint do
  email
  name
  password
  password_confirmation {password}
end

Poll.blueprint do
  title
  description
  form_url      {Sham.url}
  owner         {User.make}
end

Question.blueprint do
  title
  description
  kind          {:text}
  poll          {Poll.make}
end

Question.blueprint(:options) do
  title
  description
  kind          {:options}
  poll          {Poll.make}
  options       {(0..rand(3)+1).map{Sham.name}}
end

Question.blueprint(:numeric) do
  title
  description
  kind          {:numeric}
  poll          {Poll.make}
  numeric_min   {rand(3)+1}
  numeric_max   {rand(3)+5}
end