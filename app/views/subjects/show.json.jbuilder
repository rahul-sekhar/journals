json.(@subject, :name, :id)

json.strands @subject.root_strands do |strand|
  json.partial! "strand", strand: strand
end