class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :firstname, :lastname, :admin
end
