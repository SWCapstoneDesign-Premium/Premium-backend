class OptionSerializer < Panko::Serializer
  attributes :id, :weight, :start_at, :end_at, :holiday, :status

  has_one :chapter, serializer: ChapterSerializer
end