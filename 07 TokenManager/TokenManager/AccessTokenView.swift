//
//  TokenView.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct AccessTokenView: View {
    var accessToken: String?
    
    var body: some View {
        if accessToken != nil {
            Section(header: Text("Access Token (memory-only)")) {
                LabeledContent {
                    // FIXME incorrectly hypenates the token
                    Text(accessToken!).frame(maxHeight: 200)
                } label: {
                    Text("access_token")
                }
            }
        } else {
            Section {
                Text("No access token")
            }
        }
    }
}

#Preview {
    Form {
        AccessTokenView(accessToken: "Anim_do_in_mollit_ullamco_amet_esse_in_minim_ullamco_amet_enim_id_pariatur_tempor_culpa_enim_lorem_officia_aliqua_culpa_exercitation_laborum_sit_adipiscing_ea_exercitation_nulla_sint_consectetur_ea_labore_nulla_voluptate_commodo_eu_labore_reprehenderit_ven")
    }
}
