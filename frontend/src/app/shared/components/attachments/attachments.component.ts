// -- copyright
// OpenProject is an open source project management software.
// Copyright (C) 2012-2022 the OpenProject GmbH
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See COPYRIGHT and LICENSE files for more details.
//++

import {
  Component, ElementRef, HostBinding, Input, OnInit,
} from '@angular/core';
import { HalResource } from 'core-app/features/hal/resources/hal-resource';
import { HalResourceService } from 'core-app/features/hal/services/hal-resource.service';
import { I18nService } from 'core-app/core/i18n/i18n.service';
import { States } from 'core-app/core/states/states.service';
import { filter } from 'rxjs/operators';
import { UntilDestroyedMixin } from 'core-app/shared/helpers/angular/until-destroyed.mixin';
import { populateInputsFromDataset } from '../dataset-inputs';

export const attachmentsSelector = 'op-attachments';

@Component({
  selector: attachmentsSelector,
  templateUrl: './attachments.component.html',
})
export class AttachmentsComponent extends UntilDestroyedMixin implements OnInit {
  @Input('resource') public resource:HalResource;

  @Input() public allowUploading = true;

  @Input() public destroyImmediately = true;

  @HostBinding('id.attachments_fields') public hostId = true;

  public text = {
    attachments: this.I18n.t('js.label_attachments'),
  };

  constructor(
    public elementRef:ElementRef,
    protected I18n:I18nService,
    protected states:States,
    protected halResourceService:HalResourceService,
  ) {
    super();

    populateInputsFromDataset(this);
  }

  ngOnInit() {
    if (!(this.resource instanceof HalResource)) {
      // Parse the resource if any exists
      this.resource = this.halResourceService.createHalResource(this.resource, true);
    }

    this.setupResourceUpdateListener();
  }

  public setupResourceUpdateListener() {
    this.states.forResource(this.resource)!.changes$()
      .pipe(
        this.untilDestroyed(),
        filter((newResource) => !!newResource),
      )
      .subscribe((newResource:HalResource) => {
        this.resource = newResource || this.resource;
      });
  }

  // Only show attachment list when allow uploading is set
  // or when at least one attachment exists
  public showAttachments() {
    return this.allowUploading || _.get(this.resource, 'attachments.count', 0) > 0;
  }
}
