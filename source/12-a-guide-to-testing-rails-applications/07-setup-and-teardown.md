# Setup и Teardown

Если хотите запустить блок кода до старта каждого теста и другой блок кода после окончания каждого теста, у Вас есть два специальных колбэка для этой цели. Давайте рассмотрим это на примере нашего функционального теста для контроллера `Posts`:

```ruby
require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  # вызывается перед каждым отдельным тестом
  def setup
    @post = posts(:one)
  end

  # вызывается после каждого отдельного теста
  def teardown
    # так как мы пересоздаем @post перед каждым тестом,
    # установка его в nil тут не обязательна, но, я надеюсь,
    # Вы поняли, как использовать метод teardown
    @post = nil
  end

  test "should show post" do
    get :show, :id => @post.id
    assert_response :success
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @post.id
    end

    assert_redirected_to posts_path
  end

end
```

В вышеприведенном, метод `setup` вызывается перед каждым тестом, таким образом `@post` доступна каждому из тестов. Rails выполняет `setup` и `teardown` как ActiveSupport::Callbacks. Что по существу означает, что можно использовать `setup` и `teardown` не только как методы в своих тестах. Можете определить их, используя:

* блок
* метод (как в вышеприведенном примере)
* имя метода как символ
* lambda

Давайте рассмотрим предыдущий пример, определив колбэк `setup` указав имя метода как символ:

```ruby
require '../test_helper'

class PostsControllerTest < ActionController::TestCase

  # called before every single test
  setup :initialize_post

  # called after every single test
  def teardown
    @post = nil
  end

  test "should show post" do
    get :show, :id => @post.id
    assert_response :success
  end

  test "should update post" do
    patch :update, :id => @post.id, :post => { }
    assert_redirected_to post_path(assigns(:post))
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @post.id
    end

    assert_redirected_to posts_path
  end

  private

  def initialize_post
    @post = posts(:one)
  end

end
```
