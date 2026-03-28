const TERMS_ACCEPTED_KEY = 'wo_terms_accepted';

interface GovernanceGateProps {
  children: React.ReactNode;
}

export function GovernanceGate({ children }: GovernanceGateProps) {
  const accepted = localStorage.getItem(TERMS_ACCEPTED_KEY) === 'true';

  if (accepted) {
    return <>{children}</>;
  }

  return (
    <div className="fixed inset-0 z-[9999] bg-navy flex items-center justify-center p-6">
      <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-8 text-center">
        <h1 className="text-2xl font-bold text-navy mb-2">Widows &amp; Orphans</h1>
        <p className="text-sm text-chrome mb-6">Community Care Platform</p>
        <div className="bg-gray-50 rounded-lg p-4 mb-6 text-left">
          <h2 className="font-semibold text-navy mb-2">Terms of Use</h2>
          <p className="text-sm text-gray-700 leading-relaxed">
            Widows &amp; Orphans is a community care tool. By continuing, you agree to
            use this platform respectfully and not to misuse it.
          </p>
        </div>
        <button
          onClick={() => {
            localStorage.setItem(TERMS_ACCEPTED_KEY, 'true');
            window.location.reload();
          }}
          className="w-full bg-navy text-white font-semibold py-3 px-6 rounded-lg hover:bg-navy/90 transition-colors"
          aria-label="Accept terms and continue"
        >
          I Agree — Continue
        </button>
      </div>
    </div>
  );
}
