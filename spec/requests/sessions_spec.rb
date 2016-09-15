# frozen_string_literal: true

require 'rails_helper'

shared_examples 'resource requiring authorization' do
  let(:session) { create(:session) }

  it 'is inaccessible without token' do
    subject.call
    expect(response).to be_unauthorized
  end

  it 'is inaccessible with invalid token' do
    invalid_session_id = Session.count + 2
    subject.call(headers: {authorization: "Token #{invalid_session_id}"})
    expect(response).to be_unauthorized
  end

  it 'is accessible with valid token' do
    subject.call(headers: {authorization: "Token #{session.id}"})
    expect(response).to be_ok
  end
end

describe 'Sessions resource' do
  describe '#create' do
    let(:user) { create(:user, password: 'correct password') }

    it 'fails with email not registered' do
      post sessions_path, params: {email: 'not-registered@example.com'}
      expect(response).to be_not_found
      expect(response.parsed_body.with_indifferent_access).to include(
        error: a_hash_including(
          email: a_string_including('not-registered@example.com')
        )
      )
    end

    it 'fails with wrong password' do
      post sessions_path, params: {email: user.email, password: 'wrong password'}
      expect(response).to be_unprocessable
      expect(response.parsed_body.with_indifferent_access).to include(
        error: a_hash_including(
          password: a_kind_of(String)
        )
      )
      expect(response.body).to include('password')
    end

    it 'returns usable token' do
      post sessions_path, params: {email: user.email, password: 'correct password'}
      expect(response).to be_ok
      expect(response.parsed_body.with_indifferent_access).to include(:token)
      token = response.parsed_body['token']
      get sessions_path, headers: {authorization: "Token #{token}"}
      expect(response).to be_ok
    end
  end

  describe '#index' do
    subject { Proc.new { |*options| get sessions_path, *options} }
    it_behaves_like 'resource requiring authorization'
  end

  describe '#update' do
    subject { Proc.new { |*options| patch session_path(session), *options } }
    it_behaves_like 'resource requiring authorization'
  end

  describe '#destroy' do
    subject { Proc.new { |*options| delete session_path(session), *options } }
    it_behaves_like 'resource requiring authorization'
  end
end
