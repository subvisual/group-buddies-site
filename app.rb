Dotenv.load

require './helpers/helpers.rb'
require './config/initializers/load_keys.rb'

configure do
  set :sass, style: :compressed

  set :gb, Gibbon.new(KEYS['mailchimp'])
  set :list_id, settings.gb.lists(filters: { list_name: 'gbnews' })['data'].first['id']
end

get '/stylesheets/:filename.css' do
  content_type 'text/css', charset: 'utf-8'
  filename = "#{params[:filename]}"
  render :sass, filename.to_sym, views: './views/stylesheets'
end

get '/stylesheets/:folder/:filename.css' do
  content_type 'text/css', charset: 'utf-8'
  filename = "#{params[:filename]}"
  render :sass, filename.to_sym, views: "./views/stylesheets/#{params[:folder]}"
end

get '/' do
  @stylesheets = ['/stylesheets/reset.css', '/stylesheets/index/structure.css', '/stylesheets/index/typography.css', '/stylesheets/font-awesome.css']
  @javascripts = ['/javascripts/jquery.js', '/javascripts/jquery-ui.min.js', '/javascripts/jquery.touchdown.min.js', '/javascripts/application.js', '/javascripts/index.js', '/javascripts/preloadCssImages.jQuery_v5.js']

  erb :index
end

post '/contact' do
  Pony.mail to: 'contact@groupbuddies.com',
            from: params[:email],
            reply_to: params[:email],
            subject: '[groupbuddies.com] Message from ' + params[:name],
            body: params[:message],
            via: :smtp,
            via_options: {
              address:              'smtp.gmail.com',
              port:                 '587',
              enable_starttls_auto: true,
              user_name:            ENV['NOREPLY_USERNAME'],
              password:             ENV['NOREPLY_PASSWORD'],
              authentication:       :plain # :plain, :login, :cram_md5, no auth by default
            }

  redirect to('/') unless request.xhr?
end

get '/portfolio/:name' do
  @stylesheets = ['/stylesheets/reset.css', '/stylesheets/portfolio/structure.css', '/stylesheets/portfolio/typography.css']
  @javascripts = ['/javascripts/jquery.js', '/javascripts/jquery-ui.min.js', '/javascripts/jquery.touchdown.min.js', '/javascripts/application.js', '/javascripts/portfolio.js', '/javascripts/preloadCssImages.jQuery_v5.js']

  @name = params[:name]

  erb :portfolio
end

post '/newsletter' do
  email_regex = /^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/

  if params[:email] =~ email_regex && !email_exists?('newsletter.txt', params[:email])
    add_to_newsletter('newsletter.txt', params[:email])

    settings.gb.listSubscribe id: settings.list_id,
                              email_address: params[:email],
                              merge_vars: { fname: 'GB', lname: 'User' },
                              double_optin: false,
                              send_welcome: true
    200
  else
    500
  end
end

error 404 do
  redirect to '/'
end
