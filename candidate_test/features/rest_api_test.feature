# Gherkin file where desire behaviour is described from a business perspective

# encoding: UTF-8
# language: ru

#Readme
# Данный тест - проверка навыков работы с REST API
# Мы используем Gem RestClient
# Для облегчения работы в тесте есть обертка над этим гемом features/support/helpers/rest_wrapper.rb

# Ваша задача
# 1. Реализовать шаг удаления пользователя по логину ( логин - уникальный параметр для пользователя)
# 2. Реализовать шаг изменения доступных параметров пользователя по логину
# 3. Провести исследовательское тестирование работы реализованных REST API сервисов (независимо и в связках)

Функция: REST API

  Сценарий: Работа с пользователями через REST API

    Дано получаю информацию о пользователях

    И проверяю наличие логина i.ivanov в списке пользователей
    И проверяю отсутствие логина f.akelogin в списке пользователей

    Тогда добавляю пользователя c логином t.task именем testing фамилией task паролем Qwerty123@
    И нахожу пользователя с логином t.task

  # --- NEW SCENARIO: Delete an existing user ---
  Сценарий: Удаление существующего пользователя

    # Ensure the user doesn't exist from previous runs, then create them for this test
    Когда добавляю пользователя c логином user.to.delete именем Delete фамилией MeUser паролем Password123!
    И нахожу пользователя с логином user.to.delete
    Тогда удаляю пользователя с логином user.to.delete
    И проверяю отсутствие логина user.to.delete в списке пользователей

  # --- NEW SCENARIO: Update an existing user ---
  Сценарий: Изменение параметров существующего пользователя

    # Create a user to modify
    Когда добавляю пользователя c логином user.to.edit именем Initial фамилией DataUser паролем OldPassword!
    И нахожу пользователя с логином user.to.edit
    Тогда изменяю параметры пользователя с логином user.to.edit на:
      | name    | ChangedFirstName    |
      | surname | ChangedLastName     |
      | active  | false               | # Example of changing 'active' status

  # --- NEW SCENARIO: Exploratory Testing Example ---
  Сценарий: Исследовательское тестирование - создание, изменение и удаление

    # Create two users
    Когда добавляю пользователя c логином exp.user1 именем Alice фамилией Wonderland паролем Pass1!
    И добавляю пользователя c логином exp.user2 именем Bob фамилией Builder паролем Pass2!

    # Modify the first user
    Тогда изменяю параметры пользователя с логином exp.user1 на:
      | name  | Alicia       |
      | active | true        |

    # Delete the second user
    И удаляю пользователя с логином exp.user2
    И проверяю отсутствие логина exp.user2 в списке пользователей

    # Delete the first user as cleanup
    И удаляю пользователя с логином exp.user1
    И проверяю отсутствие логина exp.user1 в списке пользователей

  # --- NEW SCENARIO: Handle non-existent user deletion ---
  Сценарий: Исследовательское тестирование - Попытка удалить несуществующего пользователя
    # We expect this to fail, or raise an informative error
    Тогда удаляю пользователя с логином non.existent.user

  # --- NEW SCENARIO: Handle non-existent user update ---
  Сценарий: Исследовательское тестирование - Попытка изменить несуществующего пользователя
    # We expect this to fail, or raise an informative error
    Тогда изменяю параметры пользователя с логином non.existent.user2 на:
      | name  | NewName |