<?php
/**
 * @author Lukas Reschke <lukas@owncloud.com>
 * @author Thomas Müller <thomas.mueller@tmit.eu>
 *
 * @copyright Copyright (c) 2016, ownCloud, Inc.
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */
namespace OCA\DAV\CalDAV;

use Sabre\CalDAV\Backend\NotificationSupport;
use Sabre\CalDAV\Backend\SchedulingSupport;
use Sabre\CalDAV\Backend\SubscriptionSupport;
use Sabre\CalDAV\Schedule\Inbox;
use Sabre\CalDAV\Schedule\Outbox;
use Sabre\CalDAV\Subscriptions\Subscription;
use Sabre\DAV\Exception\NotFound;

class CalendarHome extends \Sabre\CalDAV\CalendarHome {

	/**
	 * @inheritdoc
	 */
	function getChildren() {
		$calendars = $this->caldavBackend->getCalendarsForUser($this->principalInfo['uri']);
		$objs = [];
		foreach ($calendars as $calendar) {
			$objs[] = new Calendar($this->caldavBackend, $calendar);
		}

		if ($this->caldavBackend instanceof SchedulingSupport) {
			$objs[] = new Inbox($this->caldavBackend, $this->principalInfo['uri']);
			$objs[] = new Outbox($this->principalInfo['uri']);
		}

		// We're adding a notifications node, if it's supported by the backend.
		if ($this->caldavBackend instanceof NotificationSupport) {
			$objs[] = new \Sabre\CalDAV\Notifications\Collection($this->caldavBackend, $this->principalInfo['uri']);
		}

		// If the backend supports subscriptions, we'll add those as well,
		if ($this->caldavBackend instanceof SubscriptionSupport) {
			foreach ($this->caldavBackend->getSubscriptionsForUser($this->principalInfo['uri']) as $subscription) {
				$objs[] = new Subscription($this->caldavBackend, $subscription);
			}
		}

		return $objs;
	}

	/**
	 * @inheritdoc
	 */
	function getChild($name) {
		// Special nodes
		if ($name === 'inbox' && $this->caldavBackend instanceof SchedulingSupport) {
			return new Inbox($this->caldavBackend, $this->principalInfo['uri']);
		}
		if ($name === 'outbox' && $this->caldavBackend instanceof SchedulingSupport) {
			return new Outbox($this->principalInfo['uri']);
		}
		if ($name === 'notifications' && $this->caldavBackend instanceof NotificationSupport) {
			return new \Sabre\CalDAv\Notifications\Collection($this->caldavBackend, $this->principalInfo['uri']);
		}

		// Calendars
		foreach ($this->caldavBackend->getCalendarsForUser($this->principalInfo['uri']) as $calendar) {
			if ($calendar['uri'] === $name) {
				return new Calendar($this->caldavBackend, $calendar);
			}
		}

		if ($this->caldavBackend instanceof SubscriptionSupport) {
			foreach ($this->caldavBackend->getSubscriptionsForUser($this->principalInfo['uri']) as $subscription) {
				if ($subscription['uri'] === $name) {
					return new Subscription($this->caldavBackend, $subscription);
				}
			}

		}

		throw new NotFound('Node with name \'' . $name . '\' could not be found');
	}
}