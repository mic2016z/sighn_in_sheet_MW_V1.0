require "prawn"

# Renders one day's sign-in sheet as a printable/archivable landscape PDF,
# with each person's captured signature embedded next to their row —
# the digital equivalent of the paper register.
class RegisterPdf
  ROW_HEIGHT = 34
  HEADER_HEIGHT = 26
  COLUMNS = {
    name: 165, time_in: 65, time_out: 70, duration: 45,
    program: 115, location: 105, signature: 140
  }.freeze

  def initialize(organisation:, date:, location:, visits:)
    @organisation = organisation
    @date = date
    @location = location
    @visits = visits
    @tz = organisation.timezone
  end

  def render
    pdf = Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: 36)
    pdf.font_families.update(
      "Helvetica" => { normal: "Helvetica", bold: "Helvetica-Bold" }
    )

    draw_title(pdf)
    draw_header_row(pdf)
    @visits.each { |visit| draw_visit_row(pdf, visit) }
    draw_footer(pdf)

    pdf.render
  end

  private

  def draw_title(pdf)
    pdf.text @organisation.name, size: 18, style: :bold
    subtitle = [ @location&.name || "All locations", @date.strftime("%A, %-d %B %Y") ].join(" · ")
    pdf.text subtitle, size: 11, color: "666666"
    pdf.move_down 12
  end

  def draw_header_row(pdf)
    x = pdf.bounds.left
    y = pdf.cursor
    pdf.fill_color "F1F5F9"
    pdf.fill_rectangle [ x, y ], pdf.bounds.width, HEADER_HEIGHT
    pdf.fill_color "000000"

    pdf.font_size(9) do
      col_x = x
      COLUMNS.each do |key, width|
        pdf.draw_text label_for(key), at: [ col_x + 4, y - 17 ], style: :bold, size: 8
        col_x += width
      end
    end
    pdf.move_down HEADER_HEIGHT + 4
  end

  def label_for(key)
    { name: "Name", time_in: "In", time_out: "Out", duration: "Hrs",
      program: "Program", location: "Location", signature: "Signature" }[key]
  end

  def draw_visit_row(pdf, visit)
    ensure_room(pdf)

    x = pdf.bounds.left
    y = pdf.cursor
    row_bottom = y - ROW_HEIGHT

    if visit.auto_closed?
      pdf.fill_color "FEF3C7"
      pdf.fill_rectangle [ x, y ], pdf.bounds.width, ROW_HEIGHT
      pdf.fill_color "000000"
    end

    col_x = x
    pdf.font_size(9) do
      pdf.draw_text truncate(visit.person_name, 26), at: [ col_x + 4, y - 14 ]
      col_x += COLUMNS[:name]

      pdf.draw_text visit.signed_in_at.in_time_zone(@tz).strftime("%-l:%M %p"), at: [ col_x + 4, y - 14 ]
      col_x += COLUMNS[:time_in]

      out_text = visit.signed_out_at ? visit.signed_out_at.in_time_zone(@tz).strftime("%-l:%M %p") : "—"
      out_text += "*" if visit.auto_closed?
      pdf.draw_text out_text, at: [ col_x + 4, y - 14 ]
      col_x += COLUMNS[:time_out]

      pdf.draw_text visit.duration_hours.to_s, at: [ col_x + 4, y - 14 ]
      col_x += COLUMNS[:duration]

      pdf.draw_text truncate(visit.program.presence || "—", 16), at: [ col_x + 4, y - 14 ]
      col_x += COLUMNS[:program]

      pdf.draw_text truncate(visit.location.name, 16), at: [ col_x + 4, y - 14 ]
      col_x += COLUMNS[:location]
    end

    draw_signature(pdf, visit, col_x, y)

    pdf.stroke_color "E2E8F0"
    pdf.stroke_horizontal_line x, pdf.bounds.width, at: row_bottom
    pdf.move_down ROW_HEIGHT
  end

  def draw_signature(pdf, visit, col_x, y)
    return unless visit.signed?

    io = StringIO.new(visit.signature_png_bytes)
    pdf.image io, at: [ col_x + 4, y - 4 ], fit: [ COLUMNS[:signature] - 8, ROW_HEIGHT - 10 ]
  rescue StandardError
    pdf.font_size(8) { pdf.draw_text "(signature)", at: [ col_x + 4, y - 14 ] }
  end

  def ensure_room(pdf)
    return if pdf.cursor > ROW_HEIGHT + 20

    pdf.start_new_page(layout: :landscape)
    draw_header_row(pdf)
  end

  def draw_footer(pdf)
    pdf.move_down 8
    pdf.font_size(9) do
      total_hours = @visits.sum(&:duration_hours).round(1)
      pdf.text "#{@visits.size} sign-ins · #{total_hours} total hours", style: :bold, color: "334155"
      pdf.text "* auto-closed — nobody signed out; time shown is the organisation's default", color: "92400E", size: 8 if @visits.any?(&:auto_closed?)
    end
  end

  def truncate(text, length)
    text.to_s.length > length ? "#{text.to_s[0, length - 1]}…" : text.to_s
  end
end
