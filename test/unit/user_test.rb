require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
=begin
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_user
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_create_and_start_in_pending_state
    user = create_user
    user.reload
    assert user.pending?
  end


  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:boudejo).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:boudejo), User.authenticate('boudejo', 'new password')
  end

  def test_should_not_rehash_password
    users(:boudejo).update_attributes(:login => 'boudejo2')
    assert_equal users(:boudejo), User.authenticate('boudejo2', 'nonetw')
  end

  def test_should_authenticate_user
    assert_equal users(:boudejo), User.authenticate('boudejo', 'nonetw')
  end

  def test_should_set_remember_token
    users(:boudejo).remember_me
    assert_not_nil users(:boudejo).remember_token
    assert_not_nil users(:boudejo).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:boudejo).remember_me
    assert_not_nil users(:boudejo).remember_token
    users(:boudejo).forget_me
    assert_nil users(:boudejo).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:boudejo).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:boudejo).remember_token
    assert_not_nil users(:boudejo).remember_token_expires_at
    assert users(:boudejo).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:boudejo).remember_me_until time
    assert_not_nil users(:boudejo).remember_token
    assert_not_nil users(:boudejo).remember_token_expires_at
    assert_equal users(:boudejo).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:boudejo).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:boudejo).remember_token
    assert_not_nil users(:boudejo).remember_token_expires_at
    assert users(:boudejo).remember_token_expires_at.between?(before, after)
  end

  def test_should_register_passive_user
    user = create_user(:password => nil, :password_confirmation => nil)
    assert user.passive?
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    user.register!
    assert user.pending?
  end

  def test_should_suspend_user
    users(:boudejo).suspend!
    assert users(:boudejo).suspended?
  end

  def test_suspended_user_should_not_authenticate
    users(:boudejo).suspend!
    assert_not_equal users(:boudejo), User.authenticate('boudejo', 'test')
  end

  def test_should_unsuspend_user_to_active_state
    users(:boudejo).suspend!
    assert users(:boudejo).suspended?
    users(:boudejo).unsuspend!
    assert users(:boudejo).active?
  end

  def test_should_unsuspend_user_with_nil_activation_code_and_activated_at_to_passive_state
    users(:boudejo).suspend!
    User.update_all :activation_code => nil, :activated_at => nil
    assert users(:boudejo).suspended?
    users(:boudejo).reload.unsuspend!
    assert users(:boudejo).passive?
  end

  def test_should_unsuspend_user_with_activation_code_and_nil_activated_at_to_pending_state
    users(:boudejo).suspend!
    User.update_all :activation_code => 'foo-bar', :activated_at => nil
    assert users(:boudejo).suspended?
    users(:boudejo).reload.unsuspend!
    assert users(:boudejo).pending?
  end

  def test_should_delete_user
    assert_nil users(:boudejo).deleted_at
    users(:boudejo).delete!
    assert_not_nil users(:boudejo).deleted_at
    assert users(:boudejo).deleted?
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.register! if record.valid?
    record
  end
=end
end
