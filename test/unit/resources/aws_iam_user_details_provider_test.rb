# author: Steffanie Freeman
# author: Adnan Duric
require 'aws-sdk'
require 'helper'
require 'aws_iam_user_details_provider'

class AwsIamUserDetailsProviderTest < Minitest::Test
  Username = "test"
  def setup
    @mock_iam_resource = Minitest::Mock.new
    @mock_iam_resource_user = Minitest::Mock.new
  end

  def test_has_mfa_enabled_returns_true
    @mock_iam_resource_user.expect :mfa_devices, ['device']
    assert AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).has_mfa_enabled?
  end

  def test_has_mfa_enabled_returns_false
    @mock_iam_resource_user.expect :mfa_devices, []
    refute AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).has_mfa_enabled?
  end
  
  def test_has_console_password_returns_true
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, 'date'
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    assert AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).has_console_password?
  end

  def test_has_console_password_returns_false
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    refute AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).has_console_password?
  end
  
  def test_has_console_password_returns_false_when_nosuchentity
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do |args|
      raise Aws::IAM::Errors::NoSuchEntity.new(nil, nil)
    end
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    refute AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).has_console_password?
  end
  
  def test_has_console_password_throws
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do |args|
      raise ArgumentError
    end
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    
    assert_raises ArgumentError do
      AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).has_console_password?
    end
  end

  def test_access_keys_returns_access_keys
    access_key = Object.new
    @mock_iam_resource_user.expect :access_keys, [access_key]

    assert_equal [access_key], AwsIam::UserDetailsProvider.new(@mock_iam_resource_user).access_keys
  end
end