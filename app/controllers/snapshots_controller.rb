# frozen_string_literal: true

class SnapshotsController < ApplicationController
  include Snapshotable
  before_action :authenticate_user! # you are already calling this in the parent controller
  before_action :set_snapshot, only: %i[show edit update destroy]
end
