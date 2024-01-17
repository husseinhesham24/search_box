150.times do
  Article.create(
    title: Faker::Book.title,
    body: Faker::Lorem.paragraph(sentence_count: 10)
  )
end