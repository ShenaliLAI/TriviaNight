import Foundation
import MultipeerConnectivity
import Combine

enum MultipeerRole {
    case host
    case client
}

final class MultipeerManager: NSObject, ObservableObject {
    static let serviceType = "trivnight" // up to 15 ASCII chars

    @Published private(set) var role: MultipeerRole
    @Published private(set) var sessionID: String
    @Published private(set) var connectedPeers: [MCPeerID] = []
    @Published private(set) var lastError: Error?

    let localPeerID: MCPeerID
    private let session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    let didReceiveMessage = PassthroughSubject<TriviaMessage, Never>()

    init(role: MultipeerRole, displayName: String, sessionID: String? = nil) {
        self.role = role
        self.localPeerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.sessionID = sessionID ?? MultipeerManager.randomSessionID()
        super.init()
        self.session.delegate = self

        switch role {
        case .host:
            startAdvertising()
        case .client:
            startBrowsing()
        }
    }

    // MARK: - Hosting / Browsing

    private func startAdvertising() {
        let info = ["sessionID": sessionID]
        let advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: info, serviceType: Self.serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser
    }

    private func startBrowsing() {
        let browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: Self.serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
    }

    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session.disconnect()
    }

    // MARK: - Messaging

    func send(_ message: TriviaMessage, to peers: [MCPeerID]? = nil) {
        do {
            let data = try JSONEncoder().encode(message)
            let targetPeers = peers ?? session.connectedPeers
            if !targetPeers.isEmpty {
                try session.send(data, toPeers: targetPeers, with: .reliable)
            }
        } catch {
            DispatchQueue.main.async {
                self.lastError = error
            }
        }
    }

    // Host convenience: broadcast to all clients.
    func broadcast(_ message: TriviaMessage) {
        send(message)
    }

    // Client convenience: send to host (assumes single host peer in session).
    func sendToHost(_ message: TriviaMessage) {
        guard let hostPeer = session.connectedPeers.first else { return }
        send(message, to: [hostPeer])
    }

    // MARK: - Session helpers

    private func updateConnectedPeers() {
        DispatchQueue.main.async {
            self.connectedPeers = self.session.connectedPeers
        }
    }

    static func randomSessionID(length: Int = 5) -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<length).compactMap { _ in chars.randomElement() })
    }
}

// MARK: - MCSessionDelegate

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        updateConnectedPeers()
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(TriviaMessage.self, from: data) {
            DispatchQueue.main.async {
                self.didReceiveMessage.send(message)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Host auto-accepts invitations for the correct session ID.
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            self.lastError = error
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Only invite peers that match the desired sessionID.
        if let advertisedSession = info?["sessionID"], advertisedSession == sessionID {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 20)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async {
            self.lastError = error
        }
    }
}
