# encoding:utf-8

FactoryGirl.define do

  factory :user1, class: User do
    name "Иван Стрельников"
  end

  factory :user2, class: User do
    name "Петр Самойлов"
  end

  factory :user3, class: User do
    name "Дмитрий Краснов"
  end

  factory :user4, class: User do
    name "Олег Востряков"
  end
end
