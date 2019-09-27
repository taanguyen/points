class RealScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project

  def edit
    @stories = @project.stories
  end

  def update
    values = params[:stories].to_unsafe_hash.transform_keys{|k| k.gsub("story_", '')}
    values.each do |id,score|
      @project.stories.find{|story| story.id == id.to_i}.update(real_score: score)
    end
    redirect_to @project
  end

private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def stories_params
    params.require(:story).permit(:title, :description, :project_id)
  end

end
