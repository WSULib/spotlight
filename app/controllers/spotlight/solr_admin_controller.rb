module Spotlight
  class SolrAdminController < Spotlight::ApplicationController
    def index
      solr_response = Faraday.get("#{ENV['SOLR_URL']}/dataimport?command=status")
      solr_data = JSON.parse(solr_response.body)
      @status = solr_data['status']

      if @status != 'idle'
        feed_data = Faraday.get ENV['FEED_URL']
        @completed = solr_data['statusMessages']['Total Rows Fetched'].to_f
        @total = Nokogiri::XML(feed_data.body).css('resumptionToken').first['completeListSize'].to_f
        @progress = (@completed / @total * 100).round(0)
      else
        @completed = 0
        @total = 0
        @progress = 0
      end
    end

    def update
      puts "Updating Solr index"
      Faraday.get "#{ENV['SOLR_URL']}/dataimport?command=full-import&clean=false"
      redirect_to site_solr_admin_index_path, notice: 'Updating Solr index'
    end

    def reindex
      backup = Spotlight::Exhibit.export_all
      if backup.messages.any? || !backup.save
        redirect_to action: :index, alert: messages
      else
        puts "Reindexing Solr index"
        Faraday.get "#{ENV['SOLR_URL']}/dataimport?command=full-import&clean=true"
        redirect_to site_solr_admin_index_path, notice: 'Reindexin Solr index'
      end
    end

    def status
      solr_response = Faraday.get("#{ENV['SOLR_URL']}/dataimport?command=status")
      solr_data = JSON.parse(solr_response.body)
      @status = solr_data['status']

      if @status != 'idle'
        @completed = solr_data['statusMessages']['Total Rows Fetched'].to_f
        render json: {status: @status, completed: @completed}
      else
        render json: {status: @status}
      end
    end
  end
end
