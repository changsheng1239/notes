# Tips & Troubleshooting

## Gitlab

1. Update user role to admin

	```ruby
	gitlab-rails console -e production
	user = User.find_by(username: 'user')
	user.admin = true 
	user.save exit
	```

## Registry

1. Docker login `401 Unauthorized` & server log show `error authorizing context: authorization token required`: 
    - make sure ssl certificates owner & permission is correct

