# frozen_string_literal: true

json.array! @snapshots, partial: 'snapshots/snapshot', as: :snapshot
