class ReturnExampleController < ApplicationController
  def returnExample
    #render
      #Action方法裡面空空如也，甚至不定義Action，Rails預設也還是會執行render方法。
      #這個render方法會回傳預設的Template，依照Rails慣例就是app/views/{controller_name}/{action_name}。
      #如果找不到樣板檔案的話，會出現Template is missing的錯誤。

      #直接回傳結果
        render :text => "Hello" 直接回傳字串內容，不使用任何樣板。
        render :xml => @event.to_xml 回傳XML格式
        render :json => @event.to_json 回傳JSON格式(再加上:callback就會是JSONP)
        render :nothing => true 空空如也

      #指定Template
        :template 指定Template，這也是預設採用的參數，例如render "/events/index.html.erb"
        :action 指定同一個Controller中另一個Action的Template(注意到只是使用它的Template，而不會執行該Action內的程式)

      #其他參數
        :status 設定HTTP status，預設是200，也就是正常。其他常用代碼包括401權限不足、404找不到頁面、500伺服器錯誤等。
        :layout 可以指定這個Action的Layout，設成false即關掉Layout

      #補充一提，在特定情況你想把render的結果存成一個字串，例如拿到局部樣板Partials成為一個字串，這時候可以改使用render_to_string :partial => "foobar"

    #respond to
      #respond_to可以用來回應不同的資料格式。
      #Rails內建支援格式包括有:html, :text, :js, :css, :ics, :csv, :xml, :rss, :atom, :yaml, :json等。
      #如果需要擴充，可以編輯config/initializers/mime_types.rb這個檔案。
      respond_to do |format|
        format.html
        format.xml { render :xml => @event.to_xml }
        format.any { render :text => "WTF" }
      end

      #response to different type
        #Template的命名則是index.html+phone.erb和index.html+tablet.erb。
        respond_to do |format|
          format.html
          format.html.phone
          format.html.tablet
        end

      #Json Respond to
        #create
          respond_to do |format|
            if @person.save
              format.html { redirect_to @person, notice: 'Person was successfully created.' }
              format.json { render :show, status: :created, location: @person }
            else
              format.html { render :new }
              format.json { render json: @person.errors, status: :unprocessable_entity }
            end
          end
        #update
          respond_to do |format|
            if @person.update(person_params)
              format.html { redirect_to @person, notice: 'Person was successfully updated.' }
              format.json { render :show, status: :ok, location: @person }
            else
              format.html { render :edit }
              format.json { render json: @person.errors, status: :unprocessable_entity }
            end
          end
        #destroy
          respond_to do |format|
            format.html { redirect_to people_url, notice: 'Person was successfully destroyed.' }
            format.json { head :no_content }
          end
        #show
          respond_to do |format|
            format.html { @page_title = @event.name } # show.html.erb
            format.xml # show.xml.builder
            format.json { render :json => { id: @event.id, name: @event.name }.to_json }
          end

      #csv
       respond_to do |format|
          format.html
          format.json{ render :json => @person.to_json }
          format.xml { render :xml => @person.to_xml }
          format.csv do
            csv_string = CSV.generate do |csv|
                csv << ["Name", "Created At"]
                @people.each do |person|
                    csv << [person.name, person.created_at]
                end
            end
            render :text => csv_string
          end
        end

    #redirect
      redirect_to action: :show, :id => @event
      redirect_to events_url
      redirect_to event_location_url( @event )
      redirect_to :back #回到上一頁。

    #sending file
      send_data(data, options={}) #回傳二進位字串，接受以下參數：
      # 其中data參數是二進位的字串：
      # :filename 使用者儲存下來的檔案名稱
      # :type 預設是application/octet-stream
      # :disposition inline或attachment
      # :status 預設是200

      send_file(file_location, options={}) #回傳一個檔案，接受以下參數：

      # 其中file_location是檔案路徑和檔名：
      # :filename 使用者儲存下來的檔案名稱
      # :type 預設是application/octet-stream
      # :disposition inline或attachment
      # :status 預設是200

      #不過實務上我們很少在上線環境上直接用Rails來推送靜態檔案，
      #因為大檔的傳輸時間會浪費寶貴的Rails運算資源。
      #我們會改用X-Sendfile Header將傳檔的任務委派給網頁伺服器(例如Apache或Nginx)處理，來降低Rails伺服器的負擔。
      #或是搭配第三方雲儲存服務例如AWS S3將傳檔的任務外包出去。

#render json
render :json => { :success => true,
  :user => @user.as_json(:only => [:email]) }

  @posts.as_json(
         :only => [:title, :body, :created_at, :tags, :category],
         :except => [:password] #Or :password
         :include => [
            :likes => { :only => [:created_at], :include => [:author] },
            :comments => { only => [:created_at, :body], :include => [:author]  },
            :user => { :only => [:first_name, :last_name}, :methods => [:full_name] },
         :methods => [:likes_count, :comments_count])

#response status symble
  #render :json => { :error => e.message }, :status => :unprocessable_entity
    1xx Informational
      100 Continue  :continue
      101 Switching Protocols :switching_protocols
      102 Processing  :processing

    2xx Success
      200 OK  :ok
      201 Created :created
      202 Accepted  :accepted
      203 Non-Authoritative Information :non_authoritative_information
      204 No Content  :no_content
      205 Reset Content :reset_content
      206 Partial Content :partial_content
      207 Multi-Status  :multi_status
      226 IM Used :im_used

    3xx Redirection
      300 Multiple Choices  :multiple_choices
      301 Moved Permanently :moved_permanently
      302 Found :found
      303 See Other :see_other
      304 Not Modified  :not_modified
      305 Use Proxy :use_proxy
      307 Temporary Redirect  :temporary_redirect

    4xx Client Error
      400 Bad Request :bad_request
      401 Unauthorized  :unauthorized
      402 Payment Required  :payment_required
      403 Forbidden :forbidden
      404 Not Found :not_found
      405 Method Not Allowed  :method_not_allowed
      406 Not Acceptable  :not_acceptable
      407 Proxy Authentication Required :proxy_authentication_required
      408 Request Timeout :request_timeout
      409 Conflict  :conflict
      410 Gone  :gone
      411 Length Required :length_required
      412 Precondition Failed :precondition_failed
      413 Request Entity Too Large  :request_entity_too_large
      414 Request-URI Too Long  :request_uri_too_long
      415 Unsupported Media Type  :unsupported_media_type
      416 Requested Range Not Satisfiable :requested_range_not_satisfiable
      417 Expectation Failed  :expectation_failed
      422 Unprocessable Entity  :unprocessable_entity
      423 Locked  :locked
      424 Failed Dependency :failed_dependency
      426 Upgrade Required  :upgrade_required

    5xx Server Error
      500 Internal Server Error :internal_server_error
      501 Not Implemented :not_implemented
      502 Bad Gateway :bad_gateway
      503 Service Unavailable :service_unavailable
      504 Gateway Timeout :gateway_timeout
      505 HTTP Version Not Supported  :http_version_not_supported
      507 Insufficient Storage  :insufficient_storage
      510 Not Extended  :not_extended
  end
end
