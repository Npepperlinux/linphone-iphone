/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */


import UIKit
import Foundation
import linphonesw

class ScheduledConferencesCell: UITableViewCell {
	
	let corner_radius  = 7.0
	let border_width = 2.0
	static let button_size = 40
	let delete_checkbox_margin = 5
	
	let clockIcon = UIImageView(image: UIImage(named: "conference_schedule_time_default"))
	let timeDuration = StyledLabel(VoipTheme.conference_invite_desc_font)
	let organiser = StyledLabel(VoipTheme.conference_invite_desc_font)
	let subject = StyledLabel(VoipTheme.conference_invite_subject_font)
	let cancelledLabel = StyledLabel(VoipTheme.conference_cancelled_title_font)
	let participantsIcon = UIImageView(image: UIImage(named: "conference_schedule_participants_default"))
	let participants = StyledLabel(VoipTheme.conference_invite_desc_font)
	let infoConf = UIButton()
	
	let descriptionTitle = StyledLabel(VoipTheme.conference_invite_desc_font, VoipTexts.conference_description_title)
	let descriptionValue = StyledLabel(VoipTheme.conference_invite_desc_font)
	let urlTitle = StyledLabel(VoipTheme.conference_invite_desc_font, VoipTexts.conference_schedule_address_title)
	let urlValue = StyledLabel(VoipTheme.conference_scheduling_font)
	let copyLink  = CallControlButton(width:button_size,height:button_size,buttonTheme: VoipTheme.scheduled_conference_action("voip_copy"))
	let joinConf = FormButton(title:VoipTexts.conference_invite_join.uppercased(), backgroundStateColors: VoipTheme.button_green_background)
	let deleteConf = CallControlButton(width:button_size,height:button_size,buttonTheme: VoipTheme.scheduled_conference_action("voip_delete"))
	let editConf = CallControlButton(width:button_size,height:button_size,buttonTheme: VoipTheme.scheduled_conference_action("voip_edit"))
	var owningTableView : UITableView? = nil
	let joinEditDelete = UIStackView()
	let expandedRows = UIStackView()
	let selectionCheckBox = StyledCheckBox()

	var conferenceData: ScheduledConferenceData? = nil {
		didSet {
			if let data = conferenceData {
				timeDuration.text = "\(data.time.value)"+(data.duration.value != nil ? " ( \(data.duration.value) )" : "")
				organiser.text = VoipTexts.conference_schedule_organizer+data.organizer.value!
				subject.text = data.subject.value!
				cancelledLabel.text = data.isConferenceCancelled.value == true ? ( data.canEdit.value == true ? VoipTexts.conference_scheduled_cancelled_by_me:  VoipTexts.conference_scheduled_cancelled_by_organizer)  : nil
				cancelledLabel.isHidden = data.isConferenceCancelled.value != true
				descriptionValue.text = data.description.value!
				urlValue.text = data.address.value!
				self.joinConf.isHidden =  data.isConferenceCancelled.value == true
				self.editConf.isHidden = data.canEdit.value != true || data.isConferenceCancelled.value == true
				self.urlTitle.isHidden = data.isConferenceCancelled.value == true
				self.urlValue.isHidden = data.isConferenceCancelled.value == true
				self.copyLink.isHidden = data.isConferenceCancelled.value == true
				data.expanded.readCurrentAndObserve { expanded in
					self.contentView.backgroundColor =
							data.conferenceInfo.state == .Cancelled ? VoipTheme.voip_conference_cancelled_bg_color :
					data.isFinished ? VoipTheme.backgroundColor3.get() :  VoipTheme.backgroundColor4.get()
					self.contentView.layer.borderWidth = expanded == true ? 2.0 : 0.0
					self.descriptionTitle.isHidden = expanded != true || self.descriptionValue.text?.count == 0
					self.descriptionValue.isHidden = expanded != true  || self.descriptionValue.text?.count == 0
					self.infoConf.isSelected = expanded == true
					self.participants.text = expanded == true ? data.participantsExpanded.value : data.participantsShort.value
					self.participants.numberOfLines = expanded == true ? 6 : 2
					self.expandedRows.isHidden = expanded != true
					self.joinEditDelete.isHidden = expanded != true
					if let myAddress = Core.get().defaultAccount?.params?.identityAddress {
						self.editConf.isHidden = expanded != true || data.conferenceInfo.organizer?.weakEqual(address2: myAddress) != true
					} else {
						self.editConf.isHidden = true
					}
					self.participants.removeConstraints().alignUnder(view: self.subject,withMargin: 15).toRightOf(self.participantsIcon,withLeftMargin:10).toRightOf(self.participantsIcon,withLeftMargin:10).toLeftOf(self.infoConf,withRightMargin: 15).done()
					self.joinEditDelete.removeConstraints().alignUnder(view: self.expandedRows,withMargin: 15).alignParentRight(withMargin: 10).done()
					if (expanded == true) {
						self.joinEditDelete.alignParentBottom(withMargin: 10).done()
					} else {
						self.participants.alignParentBottom(withMargin: 10).done()
					}
					self.selectionCheckBox.liveValue = data.selectedForDeletion
				}
			}
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.layer.cornerRadius = corner_radius
		contentView.clipsToBounds = true
		contentView.backgroundColor = VoipTheme.header_background_color
		contentView.layer.borderColor = VoipTheme.primary_color.cgColor
		
		
		contentView.addSubview(clockIcon)
		clockIcon.alignParentTop(withMargin: 15).square(15).alignParentLeft(withMargin: 10).done()
		
		contentView.addSubview(timeDuration)
		timeDuration.alignParentTop(withMargin: 15).toRightOf(clockIcon,withLeftMargin:10).alignHorizontalCenterWith(clockIcon).done()
		
		contentView.addSubview(organiser)
		organiser.alignParentTop(withMargin: 15).toRightOf(timeDuration, withLeftMargin:10).alignParentRight(withMargin:10).alignHorizontalCenterWith(clockIcon).done()
		
		
		let subjectCancel = UIStackView()
		subjectCancel.axis = .vertical
		contentView.addSubview(subjectCancel)
		subjectCancel.alignUnder(view: timeDuration,withMargin: 15).alignParentLeft(withMargin: 10).done()
		
		subjectCancel.addArrangedSubview(cancelledLabel)
		subjectCancel.addArrangedSubview(subject)
		
		contentView.addSubview(participantsIcon)
		participantsIcon.alignUnder(view: subject,withMargin: 15).square(15).alignParentLeft(withMargin: 10).done()
		
		//infoConf.onClick {
		contentView.onClick {
			self.conferenceData?.toggleExpand()
			self.owningTableView?.reloadData()
		}
		contentView.addSubview(infoConf)
		infoConf.imageView?.contentMode = .scaleAspectFit
		infoConf.alignUnder(view: subject,withMargin: 15).square(30).alignParentRight(withMargin: 10).alignHorizontalCenterWith(participantsIcon).done()
		infoConf.applyTintedIcons(tintedIcons: VoipTheme.conference_info_button)
		
		
		contentView.addSubview(participants)
		participants.alignUnder(view: subject,withMargin: 15).toRightOf(participantsIcon,withLeftMargin:10).toRightOf(participantsIcon,withLeftMargin:10).toLeftOf(infoConf,withRightMargin: 15).done()
		
		expandedRows.axis = .vertical
		expandedRows.spacing = 10
		contentView.addSubview(expandedRows)
		expandedRows.alignUnder(view: participants,withMargin: 15).matchParentSideBorders(insetedByDx:10).done()
		
		expandedRows.addArrangedSubview(descriptionTitle)
		expandedRows.addArrangedSubview(descriptionValue)
		
		expandedRows.addArrangedSubview(urlTitle)
		let urlAndCopy = UIStackView()
		urlAndCopy.addArrangedSubview(urlValue)
		urlValue.backgroundColor = .white
		self.urlValue.isEnabled = false
		urlValue.alignParentLeft().done()
		urlAndCopy.addArrangedSubview(copyLink)
		copyLink.toRightOf(urlValue,withLeftMargin: 10).done()
		expandedRows.addArrangedSubview(urlAndCopy)
		copyLink.onClick {
			UIPasteboard.general.string = self.conferenceData?.address.value!
			VoipDialog.toast(message: VoipTexts.conference_schedule_address_copied_to_clipboard)
		}
		
		joinEditDelete.axis = .horizontal
		joinEditDelete.spacing = 10
		joinEditDelete.distribution = .equalSpacing
		
		contentView.addSubview(joinEditDelete)
		joinEditDelete.alignUnder(view: expandedRows,withMargin: 15).alignParentRight(withMargin: 10).done()
		
		
		joinEditDelete.addArrangedSubview(joinConf)
		joinConf.width(150).done()
		joinConf.onClick {
			let view : ConferenceWaitingRoomFragment = self.VIEW(ConferenceWaitingRoomFragment.compositeViewDescription())
			PhoneMainView.instance().changeCurrentView(view.compositeViewDescription())
			view.setDetails(subject: (self.conferenceData?.subject.value)!, url: (self.conferenceData?.address.value)!)
		}
		
		joinEditDelete.addArrangedSubview(editConf)
		editConf.onClick {
			guard let confData = self.conferenceData else {
				Log.e("Invalid conference date, unable to edit")
				VoipDialog.toast(message: VoipTexts.conference_edit_error)
				return
			}
			let infoDate = Date(timeIntervalSince1970: Double(confData.conferenceInfo.dateTime))
			ConferenceSchedulingViewModel.shared.reset()
			ConferenceSchedulingViewModel.shared.scheduledDateTime.value = infoDate
			ConferenceSchedulingViewModel.shared.description.value = confData.description.value
			ConferenceSchedulingViewModel.shared.subject.value = confData.subject.value
			ConferenceSchedulingViewModel.shared.scheduledDuration.value = ConferenceSchedulingViewModel.durationList.firstIndex(where: {$0.value == confData.conferenceInfo.duration})
			ConferenceSchedulingViewModel.shared.scheduleForLater.value = true
			ConferenceSchedulingViewModel.shared.selectedAddresses.value = []
			confData.conferenceInfo.participants.forEach {
				ConferenceSchedulingViewModel.shared.selectedAddresses.value?.append($0)
			}
			ConferenceSchedulingViewModel.shared.existingConfInfo.value = confData.conferenceInfo
			// TOODO TimeZone (as Android 14.6.2022) ConferenceSchedulingViewModel.shared.scheduledTimeZone.value = self.conferenceData?.timezone
			let view : ConferenceSchedulingView = self.VIEW(ConferenceSchedulingView.compositeViewDescription())
			PhoneMainView.instance().changeCurrentView(view.compositeViewDescription())
		}
		
		joinEditDelete.addArrangedSubview(deleteConf)
		deleteConf.onClick {
			self.askConfirmationTodeleteEntry()
		}
		contentView.addSubview(selectionCheckBox)
		selectionCheckBox.alignParentRight(withMargin: delete_checkbox_margin).alignUnder(view:organiser, withMargin: delete_checkbox_margin).done()
		ScheduledConferencesViewModel.shared.editionEnabled.readCurrentAndObserve { editing in
			self.selectionCheckBox.isHidden = editing != true
		}
		onLongClick {
			ScheduledConferencesViewModel.shared.editionEnabled.value = true
		}
	}
	
	func askConfirmationTodeleteEntry() {
		let delete = ButtonAttributes(text:VoipTexts.conference_info_confirm_removal_delete, action: {
			self.deleteEntry()
			VoipDialog.toast(message: VoipTexts.conference_info_removed)
		}, isDestructive:false)
		let cancel = ButtonAttributes(text:VoipTexts.cancel, action: {}, isDestructive:true)
		VoipDialog(message:VoipTexts.conference_info_confirm_removal, givenButtons:  [cancel,delete]).show()
	}
	
	func deleteEntry() {
		self.conferenceData?.deleteConference()
		ScheduledConferencesViewModel.shared.computeConferenceInfoList()
		self.owningTableView?.reloadData()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
