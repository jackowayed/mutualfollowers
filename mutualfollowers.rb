#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'twitter'

module Twitter
  class Base
    def all_followers_for(user, page=1)
      f = self.followers_for(user, :page => page)
      return f if f.empty?
      f + self.all_followers_for(user, page+1)
    end
  end
end
class Array
  def overlap!(arr)
    self.delete_if do |user|
      !arr.include_user?(user.screen_name)
      #arr.select {|u| u.screen_name==user.screen_name}.length > 0
    end
  end
  def include_user?(user_name)
    self.each do |u|
      return true if u.screen_name == user_name
    end
    false
  end
end


get '/' do
  @title = "appname"
  haml :index#'%h1 Hello World!'
end
get '/find_join/:user1/:user2' do
  x = Twitter::Base.new('testing42', 'testme')
  @shared = x.all_followers_for(params[:user1]).overlap!(x.all_followers_for(params[:user2]))
  @title = "People who follow " + params[:user1] + " and " + params[:user2]
 
  haml :find_join

end
get '/urlify' do
  redirect "/find_join/#{params[:user1]}/#{params[:user2]}"
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
  %p
    %a{:href => "http://twitter.com/#{user.screen_name}"}
      = user.screen_name
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
%p
  %strong
    Note:
  I know that this is really slow. It has to talk to Twitter at least twice, which is slow, and then crunch the data, which is slow. It is working, so unless it takes like a minute, have faith and don't try to reload it. You'll just lose your progress. 

@@ layout
!!!
%html
  %head
    %title
      = @title || "APPNAME"
  %body
    = yield
