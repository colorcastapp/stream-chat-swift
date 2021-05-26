---
title: Working with User
---

The User object is accessed through a `Controller`. 
There is a special type of user object which is `CurrentUser`, representing the currently signed-in user. 

```swift
/// User id of the user you want to work with
let userId = "yourUserId"

/// User controller for the intended user
let userController = chatClient.usersController(userId: userId)

/// Current user controller
let currentUserController = chatClient.currentUserController()
```

## Standard User

`CharUser` is a simple object, you can access the information and (un)mute and (un)flag the user.
```swift
let user = userController.user
print(user.name)
```

### Muting/unmuting user
```swift 
userController.mute()
userController.unmute()
```
Both functions have an optional completion block to be called when the network request is finished.
```swift 
userController.mute {
    if let error = error {
        print(error)
        return
    }
    // Successfully finished
}
```

### Flagging/Unflagging user
```swift 
userController.flag()
userController.unflag()
```
Both functions have an optional completion block to be called when the network request is finished.
```swift 
userController.flag {
    if let error = error {
        print(error)
        return
    }
    // Successfully finished
}
```

## Updating current user data

You can call update user data function on the current user controller.

```swift 
currentUserController.updateUserData(name: "Luke Skywalker")
```

You can observe the changes in user data with delegate.

```swift 
// Don't forget to keep reference to the delegate. 
// `CurrentUserController` keeps only weak reference to the delegate.
let delegate = YourDelegate()
currentUserController.delegate = delegate

currentUserController.updateUserData(name: "Luke Skywalker")

class YourDelegate: CurrentChatUserControllerDelegate {
    func currentUserController(
        _ controller: _CurrentChatUserController<ExtraData>,
        didChangeCurrentUser: EntityChange<_CurrentChatUser<ExtraData>>
    ) {
        if case let .update(user) = didChangeCurrentUser {
            print(user.name) // Luke Skywalker
        }
    }
}
```
You can use Combine to observe the changes too.
```swift
currentUserController
    .currentUserChangePublisher
    .compactMap({ (change: EntityChange<CurrentChatUser>) -> CurrentChatUser? in
        if case let .update(user) = change { return user } else { return nil }
    })
    .sink { print($0.name) } // Luke Skywalker
    .store(in: &cancellables)
```

## Observe unread count for user

To observe unread count on current user controller, you need to set a delegate. 

```swift
class YourDelegate: CurrentChatUserControllerDelegate {
    func currentUserController(
        _ controller: CurrentChatUserController, 
        didChangeCurrentUserUnreadCount count: UnreadCount
    ) {
        /// Handle the undread count
        UIApplication.shared.applicationIconBadgeNumber = count.messages
    }
}

// Don't forget to keep reference to the delegate. 
// `CurrentUserController` keeps only weak reference to the delegate.
let delegate = YourDelegate()
currentUserController.delegate = delegate
```

You can use Combine to observe unread counts too.
```swift
currentUserController
    .unreadCountPublisher
    .map(\.messages)
    .sink { UIApplication.shared.applicationIconBadgeNumber = $0 }
    .store(in: &cancellables)
```

## Change user

To change the logged in user, simply change token provider of the chatClient.

```swift 
let token = ... // Obtain the chat token from your system
chatClient.tokenProvider = .static(token)
```
