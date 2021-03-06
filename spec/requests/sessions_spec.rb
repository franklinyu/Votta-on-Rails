# frozen_string_literal: true

require 'rails_helper'
require 'support/logged_in_user'

describe 'Sessions resource' do
  describe '#create' do
    let(:user) { create(:user, password: 'correct password') }

    it 'fails with email not registered' do
      post sessions_path, params: {email: 'not-registered@example.com'}
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body.with_indifferent_access).to include(
        error: a_hash_including(
          email: a_string_including('not-registered@example.com')
        )
      )
    end

    it 'fails with wrong password' do
      post sessions_path, params: {email: user.email, password: 'wrong password'}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body.with_indifferent_access).to include(
        error: a_hash_including(
          password: a_kind_of(String)
        )
      )
    end

    it 'returns usable token' do
      post sessions_path, params: {email: user.email, password: 'correct password'}
      expect(response).to have_http_status(:created)
      expect(response.parsed_body.with_indifferent_access).to include(:token)
      token = response.parsed_body['token']
      get sessions_path, headers: {authorization: "Token #{token}"}
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when user is logged in' do
    let(:current_session) { create(:session) }

    describe '#index' do
      it 'list all the sessions for current user' do
        create(:session, user: current_session.user, comment: 'another session')
        get sessions_path
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.with_indifferent_access).to include(
          a_hash_including(comment: current_session.comment),
          a_hash_including(comment: 'another session')
        )
      end

      it 'does not leak sessions for other users' do
        create(:session, comment: 'another session')
        get sessions_path
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.with_indifferent_access).not_to include(
          a_hash_including(comment: 'another session')
        )
      end
    end

    describe '#update' do
      it 'updates the session and returns the new value' do
        target_session = create(:session, user: current_session.user, comment: 'old comment')
        patch session_path(target_session), params: {session: {comment: 'new comment'}}
        expect(target_session.reload.comment).to eq('new comment')
        expect(response.parsed_body.with_indifferent_access).to include(comment: 'new comment')
      end

      it 'rejects to update sessions for other users' do
        other_session = create(:session, comment: 'old comment')
        patch session_path(other_session), params: {session: {comment: 'new comment'}}
        expect(other_session.reload.comment).to eq('old comment')
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).not_to include('old comment')
      end

      it 'rejects invalid request' do
        invalid_session = create(:session, user: current_session.user, comment: 'old comment')
        path = session_path(invalid_session)
        invalid_session.destroy!
        patch path, params: {session: {comment: 'some comment'}}
        expect(response).to have_http_status(:not_found)
      end
    end

    describe '#destroy' do
      it 'destroys the session' do
        target_session = create(:session, user: current_session.user, comment: 'old comment')
        delete session_path(target_session)
        expect { target_session.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'rejects to delete sessions for other users' do
        other_session = create(:session)
        delete session_path(other_session)
        expect(other_session.reload).to be_valid
        expect(response).to have_http_status(:unauthorized)
      end

      it 'rejects invalid request' do
        invalid_session = create(:session, user: current_session.user, comment: 'old comment')
        path = session_path(invalid_session)
        invalid_session.destroy!
        delete path
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
