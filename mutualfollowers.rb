#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'twitter'
require 'haml'

TWIT = Twitter::Base.new(Twitter::HTTPAuth.new('testing42', 'testme'))

#Errors
class BadUser < ArgumentError; end

error BadUser do
  haml "%p Twitter is complaining about one of the users you provided. This could mean that you mistyped a username, that they protect their tweets, or that Twitter is down. This also can occur when working with users with extremely high numbers of followers."
end


get '/' do
  @title = "Mutual Followers"
  haml :index#'%h1 Hello World!'
end

get '/find_join/:user1/:user2' do
  begin
    @shared = TWIT.follower_ids(:screen_name => params[:user1]) & TWIT.follower_ids(:screen_name => params[:user2])
  rescue
    raise BadUser
  end
  @title = "People who follow " + params[:user1] + " and " + params[:user2]
 
  haml :find_join

end
get '/urlify' do
  redirect "/find_join/#{params[:user1]}/#{params[:user2]}"
end
get '/about' do
  @title = "About"
  haml :about
end




use_in_file_templates!

__END__


@@ find_join
%h1 
  People Who Follow Both
  %b
    = params[:user1]
  and
  %b
    = params[:user2]
- @shared.each do |user|
  %a{:href => "http://twitter.com/users/#{user}"}
    = user
  %br
= @shared.length
common followers

@@ index
%h1 How do I know you?
%p
  Often, someone follows you on Twitter, and you don't know who they are or how they know you. But with this currently-unnamed app, you can enter your username and theirs, and we tell you what people follow both of you, letting you know which of your friends they know. 
  
%form{:action => '/urlify', :method => 'get'}
  %p
    %label Username 1:
    %input{:type => 'text', :name => 'user1'}
  %p
    %label Username 2:
    %input{:type => 'text', :name => 'user2'}
  %input{:type => 'submit', :value => 'Compare Followers'}

@@ about
%h1 About Mutual Followers
%p 
  :markdown
    Mutual Followers is written in [Sinatra](http://sintrarb.com/), a Ruby web framework.
%p 
  I basically wrote it for fun to solve a problem that I run into often--not knowing how someone that begins following me has found me. 
:markdown
  ## Contact

  To contact me, email me at [danjdel+mf@gmail.com](mailto:danjdel+mf@gmail.com)

@@ layout
!!!
%html
  %head
    %title
      = @title || "Mutual Followers"
  %body
    = yield
    %hr
    #footer
      %a{:href=>'/'} Home
      %a{:href=>'/about'} About
      Copyright Daniel Jackoway 2009
