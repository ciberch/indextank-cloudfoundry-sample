require 'rubygems'
require 'sinatra'
require 'indextank'

before do
  @docid = "seamonkey#{rand(1122334455)}"
  @api_url = ENV["indextank_api_url"]
  @index_name = "tags"
  @itc = IndexTank::Client.new(@api_url)

  # and assume you have just one index.
  @index = @itc.indexes(@index_name)
end


after do
    if @index then
        begin
            @index.document(@docid).delete()
        rescue Exception => e
            # could not delete the document .. too bad.
            p e
        end
    end
end


get '/' do
    if @index then

        # add a document
        d = @index.document(@docid)
        d.add({:text => "some random text .. #{@docid}"})

        # search it
        docs = @index.search("random #{@docid}")

        # did we find it?
        if docs['results'].length == 1 then
            # success!
            "<h1>This is an IndexTank-powered Cloud Foundry App. </h1> <h2>it just created, searched and deleted #{@docid}</h2>"
        else
            # fail
            [ 500, "something went wrong .. the document is not indexed .. " ]
        end
    else
        # fail
        [500, "NO IndexTank provisioned ...  #{ENV['indextank_api_url']}"]
    end
end
