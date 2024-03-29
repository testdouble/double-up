require "test_helper"

module Utils
  class HumanizeNamesTest < ActiveSupport::TestCase
    setup do
      @subject = Utils::HumanizeNames.new
    end

    test "humanizes no names" do
      assert_equal "", @subject.call([])
    end

    test "humanizes one name" do
      assert_equal "Frodo", @subject.call(["Frodo"])
    end

    test "humanizes two names" do
      assert_equal "Frodo and Sam", @subject.call(["Frodo", "Sam"])
    end

    test "humanizes many names" do
      assert_equal "Frodo, Sam, and Pippin", @subject.call(["Frodo", "Sam", "Pippin"])
    end
  end
end
