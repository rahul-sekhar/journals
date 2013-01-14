shared_examples_for "an object with sanitized content" do
  describe "sanitization" do
    it "leaves plain text as is" do
      object.content = "Some text\nwith a line break and some - normal 'symbols$#"
      object.save!
      object.content.should == "Some text\nwith a line break and some - normal 'symbols$#"
    end

    it "removes script tags" do
      object.content = "Some text with a <script>Tag</script>"
      object.save!
      object.content.should == "Some text with a Tag"
    end

    it "leaves a set of allowed tags" do
      object.content = "<p><strong>Bold text<em> and italicized</em></strong>\n<br>with a line break</p>"
      object.save!
      object.content.should == "<p><strong>Bold text<em> and italicized</em></strong>\n<br>with a line break</p>"
    end

    it "allows classes" do
      object.content = "<span class=\"blah\">Test</span>"
      object.save!
      object.content.should == "<span class=\"blah\">Test</span>"
    end

    it "repairs unclosed tags" do
      object.content = "<span class=\"blah\">Test"
      object.save!
      object.content.should == "<span class=\"blah\">Test</span>"
    end

    it "removes styles" do
      object.content = "<span style=\"color: black;\">Black</span>"
      object.save!
      object.content.should == "<span>Black</span>"
    end

    it "allows lists" do
      object.content = "<ul><li>list item</li></ul><ol><li>list item</li></ol>"
      object.save!
      object.content.should == "<ul><li>list item</li></ul><ol><li>list item</li></ol>"
    end

    it "allows images" do
      object.content = "<img src=\"blah\" width=\"5\" height=\"100\" alt=\"Something\" title=\"Something else\">"
      object.save!
      object.content.should == "<img src=\"blah\" width=\"5\" height=\"100\" alt=\"Something\" title=\"Something else\">"
    end
  end
end