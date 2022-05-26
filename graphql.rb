require 'graphql'

class ChildType < GraphQL::Schema::Object
  field :id, ID, null: false
  field :first_name, String, null: true
  field :last_name, String, null: true
end

class DirectionEnum < GraphQL::Schema::Enum
  value 'asc', value: 'ASC'
  value 'desc', value: 'DESC'
end

class ChildOrder < GraphQL::Schema::InputObject
  graphql_name 'ChildOrderTuple'

  argument :direction, DirectionEnum, required: true
  argument :key, 'ChildOrder::Values', required: true

  class Values < GraphQL::Schema::Enum
    graphql_name 'ChildOrder'

    value 'firstName', value: 'first_name'
    value 'lastName', value: 'last_name'
  end
end

class ChildResolver < GraphQL::Schema::Resolver
  type [ChildType], null: true

  argument :order, ChildOrder, required: false

  def resolve(order: nil)
    Child.all
      .then { |query| use_order(query, order) }
  end

  private

  def use_order(query, order)
    return query.order(id: :asc) unless order

    case order.key
    when 'first_name'
      query
        .reorder(first_name: order.direction.to_sym, last_name: order.direction.to_sym)
        .order(id: order.direction.to_sym)
    when 'last_name'
      query
        .reorder(last_name: order.direction.to_sym, first_name: order.direction.to_sym)
        .order(id: order.direction.to_sym)
    else
      query
        .order(id: order.direction.to_sym)
    end
  end
end

class QueryType < GraphQL::Schema::Object
  field :children, resolver: ChildResolver
end

class MeetupSchema < GraphQL::Schema
  query(QueryType)
end
