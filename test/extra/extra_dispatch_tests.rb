require 'test_helper'

class ExtraDispatchTests < ActionDispatch::IntegrationTest
  def setup
    super

    post '/responders/', responder: { type: 'Police', name: 'P-100', capacity: 5 }
    post '/responders/', responder: { type: 'Police', name: 'P-101', capacity: 1 }
    patch '/responders/P-100', responder: { on_duty: true }
    patch '/responders/P-101', responder: { on_duty: true }
  end

  test 'POST /emergencies/ will dispatch just one responder if that responder can handle the emergency completely' do
    post '/emergencies/', emergency: { code: 'E-000001', fire_severity: 0, police_severity: 2, medical_severity: 0 }
    json_response = JSON.parse(body)
    assert_equal(['P-100'], json_response['emergency']['responders'].sort)
    assert(json_response['emergency']['full_response'])
  end
end
