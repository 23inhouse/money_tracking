require "aruba_helper"

RSpec.describe "Cli presentation layer" do
  include ArubaHelper

  example "Basic example" do
    money "expenses list"
    expect(output).to match("Empty.")

    money "expenses", "create", "73.9", "euro", "food"
    expect(output).to match(%r{Created new expense with id ([\d\w]{8}).})
    
    id = output.scan(/[\d\w]{8}/)

    money "expenses", "list"
    expect(output).to match(
      %r{#{id} - ..-..-.... ..:..:..: 73\.90 euro \[food\]}
    )

    money "expenses", "update", id, "--amount", "73.95"
    expect(output).to match("Updated expense #{id}.")

    money "expenses", "list"
    expect(output).to match(
      %r{#{id} - ..-..-.... ..:..:..: 73\.95 euro \[food\]}
    )

    money "expenses", "delete", id
    expect(output).to match("Deleted expense #{id}.")

    money "expenses list"
    expect(output).to match("Empty.")
  end

  private

  def money(*args, expected_exit_status: 0)
    command = money_command(*args)
    run_simple(command)
    @last_output = output_from(command)
    assert_exit_status(expected_exit_status)
  end

  def money_command(*args)
    "bundle exec money #{args.join(" ")}"
  end

  def output
    @last_output
  end
end