require 'spec_helper'

describe Telemetry::QuestionsByPollCollector, telemetry: true do

  it 'counts questions by poll' do
    q_1_1 = Question.make! created_at: to - 1.day
    q_1_2 = Question.make! created_at: to - 10.days
    q_1_3 = Question.make! created_at: to - 10.days
    q_1_4 = Question.make! created_at: to - 12.days

    q_2_1 = Question.make! created_at: to - 1.day
    q_2_2 = Question.make! created_at: to - 30.days
    q_2_3 = Question.make! created_at: to + 1.day

    poll_1 = Poll.make! questions: [q_1_1, q_1_2, q_1_3, q_1_4], created_at: to - 15.days
    poll_2 = Poll.make! questions: [q_2_1, q_2_2, q_2_3], created_at: to - 40.days

    stats = Telemetry::QuestionsByPollCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(2)

    counters.should include({
      metric: 'questions_by_poll',
      key: {poll_id: poll_1.id},
      value: 4
    })

    counters.should include({
      metric: 'questions_by_poll',
      key: {poll_id: poll_2.id},
      value: 2
    })
  end

  it 'counts polls with 0 questions' do
    poll_1 = Poll.make! created_at: to - 5.days
    poll_2 = Poll.make! created_at: to - 1.day
    poll_3 = Poll.make! created_at: to + 1.day

    Question.make! poll: poll_2, created_at: to + 1.day
    Question.make! poll: poll_3, created_at: to + 3.days

    stats = Telemetry::QuestionsByPollCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(2)

    counters.should include({
      metric: 'questions_by_poll',
      key: {poll_id: poll_1.id},
      value: 0
    })

    counters.should include({
      metric: 'questions_by_poll',
      key: {poll_id: poll_1.id},
      value: 0
    })
  end

end
