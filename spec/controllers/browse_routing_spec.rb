require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BrowseController do

  before do
    @node = mock_model Repository::Subversion::Node, 
      :selected_revision => '120',
      :mime_type => 'text/x-ruby',
      :dir? => false, 
      :content_type => :text, 
      :size => 40,
      :content => 'Some fake file content',
      :path => 'lib/file.rb',
      :name => 'file.rb'
    @repository = mock_model(Repository::Subversion, :latest_revision => '123', :node => @node)
    @project = permit_access_with_current_project! :absolutize_path => '', :relativize_path => '', :repository => @repository
    @project.stub_association! :changesets,
      :find_by_revision => mock_model(Changeset)
  end

  it 'should correctly generate params for browse' do
    params_from(:get, '/projects/name/browse/main/sub/file.rb').should == 
      { :project_id => 'name', :controller => 'browse', :action => 'index', :path => ['main', 'sub', 'file.rb'] }    
  end

  it 'should correctly resolve params' do
    params_from(:get, '/projects/name/browse').should == 
      { :project_id => 'name', :controller => 'browse', :action => 'index', :path => [] }    
    params_from(:get, '/projects/name/browse/').should == 
      { :project_id => 'name', :controller => 'browse', :action => 'index', :path => [] }    
  end
  
  it 'should correctly generate the route for browse params' do
    route_for(:project_id => 'name', :controller => 'browse', :action => 'index', :path => ['main', 'sub', 'file.rb']).should == 
      '/projects/name/browse/main/sub/file.rb'     
    route_for(:project_id => 'name', :controller => 'browse', :action => 'index', :path => ['file.rb']).should == 
      '/projects/name/browse/file.rb'     
    route_for(:project_id => 'name', :controller => 'browse', :action => 'index', :path => 'file.rb').should == 
      '/projects/name/browse/file.rb'     
  end

  it 'should correctly generate params for revisions' do
    params_from(:get, '/projects/name/revisions/main/sub/file.rb').should == 
      { :project_id => 'name', :controller => 'browse', :action => 'revisions', :path => ['main', 'sub', 'file.rb'] }    
  end

  it 'should correctly generate the route for revisions params' do
    route_for(:project_id => 'name', :controller => 'browse', :action => 'revisions', :path => ['main', 'sub', 'file.rb']).should == 
      '/projects/name/revisions/main/sub/file.rb'     
    route_for(:project_id => 'name', :controller => 'browse', :action => 'revisions', :path => ['main', 'sub', 'file.rb'], :page => '2').should == 
      '/projects/name/revisions/main/sub/file.rb?page=2'     
  end

  it 'should correctly generate params for download' do
    params_from(:get, '/projects/name/download/main/sub/file.rb').should == 
      { :project_id => 'name', :controller => 'browse', :action => 'download', :path => ['main', 'sub', 'file.rb'] }    
  end

  it 'should correctly generate the route for download params' do
    route_for(:project_id => 'name', :controller => 'browse', :action => 'download', :path => ['main', 'sub', 'file.rb']).should == 
      '/projects/name/download/main/sub/file.rb'     
  end

  it 'should correctly generate params for diff' do
    params_from(:get, '/projects/name/diff/main/sub/file.rb').should == 
      { :project_id => 'name', :controller => 'browse', :action => 'diff', :path => ['main', 'sub', 'file.rb'] }    
  end

  it 'should correctly generate the route for diff params' do
    route_for(:project_id => 'name', :controller => 'browse', :action => 'diff', :path => ['main', 'sub', 'file.rb']).should == 
      '/projects/name/diff/main/sub/file.rb'     
  end

  describe 'resolution of named routes' do
    
    before do
      # make a fake request to activate named-routes methods
      get :index, :project_id => 'one'
    end

    it 'should correctly resolve project-browse-path' do
      project_browse_path('name', nil).should == '/projects/name/browse/'
      project_browse_path('name', []).should == '/projects/name/browse/'
      project_browse_path('name').should == '/projects/name/browse'
      project_browse_path('name', 'file.rb').should == '/projects/name/browse/file.rb'
      project_browse_path('name', nil, :rev => 'AF03').should == '/projects/name/browse/?rev=AF03'
    end
  
    it 'should correctly resolve project-revisions-path' do
      project_revisions_path('name', nil).should == '/projects/name/revisions/'
      project_revisions_path('name', []).should == '/projects/name/revisions/'        
      project_revisions_path('name').should == '/projects/name/revisions'
      project_revisions_path('name', ['main', 'sub', 'file.rb']).should == '/projects/name/revisions/main/sub/file.rb'         
    end
  
    it 'should correctly resolve project-download-path' do
      project_download_path('name', nil).should == '/projects/name/download/'
      project_download_path('name', []).should == '/projects/name/download/'        
      project_download_path('name').should == '/projects/name/download'
      project_download_path('name', ['main', 'sub', 'file.rb']).should == '/projects/name/download/main/sub/file.rb'         
    end
    
    it 'should correctly resolve project-diff-path' do
      project_diff_path('name', nil).should == '/projects/name/diff/'         
      project_diff_path('name', []).should == '/projects/name/diff/'         
      project_diff_path('name').should == '/projects/name/diff'
      project_diff_path('name', ['main', 'sub', 'file.rb']).should == '/projects/name/diff/main/sub/file.rb'         
    end
  
  end

end
