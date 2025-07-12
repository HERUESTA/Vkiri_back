require "test_helper"

class Api::V1::VideosControllerTest < ActionDispatch::IntegrationTest
  def setup
    # テスト用の動画データを作成
    @video1 = Video.create!(
      title: "Test Video 1",
      youtube_id: "test1",
      view_count: 1000,
      published_at: 1.day.ago,
      thumbnail_url: "https://example.com/thumb1.jpg"
    )
    
    @video2 = Video.create!(
      title: "Test Video 2", 
      youtube_id: "test2",
      view_count: 5000,
      published_at: 2.days.ago,
      thumbnail_url: "https://example.com/thumb2.jpg"
    )
    
    @video3 = Video.create!(
      title: "Test Video 3",
      youtube_id: "test3", 
      view_count: 3000,
      published_at: 3.days.ago,
      thumbnail_url: "https://example.com/thumb3.jpg"
    )
  end

  test "should get index with default sort by published_at desc" do
    get "/api/v1/videos"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    videos = json_response["videos"]
    
    # 公開日降順でソートされていることを確認
    assert_equal @video1.id, videos[0]["id"]
    assert_equal @video2.id, videos[1]["id"] 
    assert_equal @video3.id, videos[2]["id"]
  end

  test "should get index with popular sort by view_count desc" do
    get "/api/v1/videos", params: { sort: "popular" }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    videos = json_response["videos"]
    
    # 再生回数降順でソートされていることを確認
    assert_equal @video2.id, videos[0]["id"]  # 5000 views
    assert_equal @video3.id, videos[1]["id"]  # 3000 views
    assert_equal @video1.id, videos[2]["id"]  # 1000 views
  end

  test "should fallback to default sort when invalid sort parameter is provided" do
    get "/api/v1/videos", params: { sort: "invalid" }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    videos = json_response["videos"]
    
    # 無効なソートパラメータの場合はデフォルト（公開日降順）になることを確認
    assert_equal @video1.id, videos[0]["id"]
    assert_equal @video2.id, videos[1]["id"]
    assert_equal @video3.id, videos[2]["id"]
  end

  test "should maintain pagination with popular sort" do
    get "/api/v1/videos", params: { sort: "popular", page: 1, per_page: 2 }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    videos = json_response["videos"]
    pagination = json_response["pagination"]
    
    # ページネーションが正しく動作することを確認
    assert_equal 2, videos.length
    assert_equal 1, pagination["current_page"]
    assert_equal 2, pagination["total_pages"]
    assert_equal 3, pagination["total_count"]
    assert_equal 2, pagination["per_page"]
    
    # 人気順の最初の2件が返されることを確認
    assert_equal @video2.id, videos[0]["id"]  # 5000 views
    assert_equal @video3.id, videos[1]["id"]  # 3000 views
  end
end