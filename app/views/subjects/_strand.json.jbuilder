json.(strand, :name, :id, :position)

json.strands strand.child_strands do |strand|
  json.partial! "strand", strand: strand
end

json.milestones strand.milestones do |milestone|
  json.(milestone, :id, :content, :level, :position)
end