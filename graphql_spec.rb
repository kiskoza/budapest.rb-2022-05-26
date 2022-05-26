# frozen_string_literal: true

require 'byebug'
require 'faker'

require './models.rb'
require './graphql.rb'
require './factories.rb'
require './spec_helper.rb'

RSpec.describe ChildResolver, type: :graphql do
  describe 'how order works' do
    let(:query) { <<~GRAPHQL }
      query($order: ChildOrderTuple) {
        children(order: $order) {
          id
        }
      }
    GRAPHQL

    let(:variables) { { order: { key: order_key, direction: order_direction } } }

    let!(:child_1) { create(:child, first_name: 'Bob', last_name: 'Schmidt') }
    let!(:child_2) { create(:child, first_name: 'David', last_name: 'Thompson') }
    let!(:child_3) { create(:child, first_name: 'Alice', last_name: 'Reilly') }

    shared_examples 'correct ordering' do
      context 'when using ascending order' do
        let(:order_direction) { 'asc' }

        it 'has them in ascending order' do
          is_expected.to include(
            children: match(
              ascending_order.map{ |child| hash_including(id: child.id.to_s) }
            )
          )
        end
      end

      context 'when using descending order' do
        let(:order_direction) { 'desc' }

        it 'has them in descending order' do
          is_expected.to include(
            children: match(
              ascending_order.reverse.map{ |child| hash_including(id: child.id.to_s) }
            )
          )
        end
      end
    end

    context 'when order is not provided' do
      let(:variables) { {} }

      it 'orders by id by default' do
        is_expected.to include(
          children: match(
            [
              hash_including(id: child_1.id.to_s),
              hash_including(id: child_2.id.to_s),
              hash_including(id: child_3.id.to_s)
            ]
          )
        )
      end
    end

    context 'when order by first name' do
      let(:order_key) { 'firstName' }
      let(:ascending_order) { [child_3, child_1, child_2] }

      it_behaves_like 'correct ordering'
    end

    context 'when order by last name' do
      let(:order_key) { 'lastName' }
      let(:ascending_order) { [child_3, child_1, child_2] }

      it_behaves_like 'correct ordering'
    end
  end
end
