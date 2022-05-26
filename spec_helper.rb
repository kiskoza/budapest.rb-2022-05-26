require 'database_cleaner'

module GraphQLExampleGroup
  extend ActiveSupport::Concern

  included do
    metadata[:type] = :graphql

    let(:variables) { {} }
    let(:query) { <<~GRAPHQL }
      {
        __schema {
          types {
            name
          }
        }
      }
    GRAPHQL

    let(:result) do
      MeetupSchema.execute(
        query,
        variables: variables
      ).deep_symbolize_keys
    end

    subject { data }

    let(:data) { result.key?(:data) ? result[:data] : expect(result[:errors]).to(be_empty) }
    let(:errors) { result[:errors] }
  end

  RSpec.configure do |config|
    config.include self, type: :graphql
  end
end

RSpec.configure do |config|
  config.default_formatter = 'doc'
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include FactoryBot::Syntax::Methods

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
