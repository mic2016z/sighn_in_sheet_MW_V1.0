module ApplicationHelper
  AVATAR_COLORS = %w[
    bg-teal-600 bg-sky-600 bg-violet-600 bg-rose-600 bg-amber-600 bg-emerald-600 bg-indigo-600 bg-fuchsia-600
  ].freeze

  def initials(name)
    name.to_s.split.first(2).map { |w| w[0] }.join.upcase
  end

  def avatar_color(name)
    AVATAR_COLORS[name.to_s.sum % AVATAR_COLORS.size]
  end

  def avatar(name, size: "size-9 text-xs")
    tag.span initials(name),
      class: "#{size} #{avatar_color(name)} rounded-full inline-flex items-center justify-center font-bold text-white shrink-0 select-none"
  end
end
